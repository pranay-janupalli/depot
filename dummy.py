from datasets import Audio, interleave_datasets, IterableDataset, load_dataset
from typing import List, Optional
dataset_names = [ "google/fleurs", "mozilla-foundation/common_voice_11_0"]
dataset_config_names = ["hy_am", "hy-AM"]
text_column_names = ["raw_transcription","sentence"]
def load_multiple_streaming_datasets(dataset_names: List,dataset_config_names: List,splits: Optional[List] = None,text_column_names: Optional[List] = None,sampling_rate: Optional[int] = 16000,stopping_strategy: Optional[str] = "all_exhausted",**kwargs
) -> IterableDataset:

    if len(dataset_names) != len(dataset_config_names):
        raise ValueError(
            f"Ensure one config is passed for each dataset, got {len(dataset_names)} datasets and"
            f" {len(dataset_config_names)} configs."
        )

    if splits is not None and len(splits) != len(dataset_names):
        raise ValueError(
            f"Ensure one split is passed for each dataset, got {len(dataset_names)} datasets and {len(splits)} splits."
        )

    if text_column_names is not None and len(text_column_names) != len(dataset_names):
        raise ValueError(
            f"Ensure one text column name is passed for each dataset, got {len(dataset_names)} datasets and"
            f" {len(text_column_names)} text column names."
        )

    splits = splits if splits is not None else ["train" for i in range(len(dataset_names))]
    text_column_names = (text_column_names if text_column_names is not None else ["text" for i in range(len(dataset_names))])

    all_datasets = []
    # iterate over the datasets we want to interleave
    for i, dataset_name in enumerate(dataset_names):
        dataset = load_dataset(dataset_name, dataset_config_names[i], split=splits[i], streaming=True, **kwargs)
        # resample to specified sampling rate
        dataset = dataset.cast_column("audio", Audio(sampling_rate))
        #  normalise columns to ["audio", "sentence"]
        if text_column_names[i] != "sentence":
            dataset = dataset.rename_column(text_column_names[i], "sentence")
        dataset = dataset.remove_columns(set(dataset.features.keys()) - set(["audio", "sentence"]))
        all_datasets.append(dataset)

    interleaved_dataset = interleave_datasets(all_datasets, stopping_strategy=stopping_strategy)
    return interleaved_dataset
# ds = load_multiple_streaming_datasets(dataset_names, dataset_config_names=dataset_config_names, text_column_names=text_column_names,splits=["train","validation"], use_auth_token=True)

from datasets import interleave_datasets, load_dataset

def load_streaming_dataset(dataset_name, dataset_config_name, split, **kwargs):
    if "+" in split:
        # load multiple splits separated by the `+` symbol *with* streaming mode
        dataset_splits = [load_dataset(dataset_name, dataset_config_name, split=split_name, streaming=True, **kwargs) for split_name in split.split("+")]
        # interleave multiple splits to form one dataset
        interleaved_dataset = interleave_datasets(dataset_splits)
        return interleaved_dataset
    else:
        # load a single split *with* streaming mode
        dataset = load_dataset(dataset_name, dataset_config_name, split=split, streaming=True, **kwargs)
        return dataset
from datasets import IterableDatasetDict

raw_datasets = IterableDatasetDict()

raw_datasets["train"] = load_multiple_streaming_datasets(dataset_names, dataset_config_names=dataset_config_names, text_column_names=text_column_names,splits=["train","train"], use_auth_token=True)   # set split="train+validation" for low-resource
raw_datasets["test"] = load_streaming_dataset("mozilla-foundation/common_voice_11_0", "hy-AM", split="test", use_auth_token=True)
from transformers import WhisperProcessor
from transformers import WhisperForConditionalGeneration

model = WhisperForConditionalGeneration.from_pretrained("openai/whisper-large-v2")

processor = WhisperProcessor.from_pretrained("openai/whisper-large-v2", language="Armenian", task="transcribe")
from datasets import Audio

raw_datasets = raw_datasets.cast_column("audio", Audio(sampling_rate=16000))

from transformers.models.whisper.english_normalizer import BasicTextNormalizer

do_lower_case = False
do_remove_punctuation = False

normalizer = BasicTextNormalizer()

def prepare_dataset(batch):
    # load and (possibly) resample audio data to 16kHz
    audio = batch["audio"]

    # compute log-Mel input features from input audio array 
    batch["input_features"] = processor.feature_extractor(audio["array"], sampling_rate=audio["sampling_rate"]).input_features[0]
    # compute input length of audio sample in seconds
    batch["input_length"] = len(audio["array"]) / audio["sampling_rate"]
    
    # optional pre-processing steps
    transcription = batch["sentence"]
    if do_lower_case:
        transcription = transcription.lower()
    if do_remove_punctuation:
        transcription = normalizer(transcription).strip()
    
    # encode target text to label ids
    batch["labels"] = processor.tokenizer(transcription).input_ids
    return batch
vectorized_datasets = raw_datasets.map(prepare_dataset, remove_columns=list(next(iter(raw_datasets.values())).features)).with_format("torch")
max_label_length = model.config.max_length

def filter_labels(labels):
    """Filter label sequences longer than max length"""
    return len(labels) < max_label_length

vectorized_datasets = vectorized_datasets.filter(filter_labels, input_columns=["labels"])
vectorized_datasets["train"] = vectorized_datasets["train"].shuffle(
    buffer_size=500,
    seed=0,
)
max_input_length = 30.0

def is_audio_in_length_range(length):
    return length < max_input_length
vectorized_datasets["train"] = vectorized_datasets["train"].filter(
    is_audio_in_length_range,
    input_columns=["input_length"],
)
import torch

from dataclasses import dataclass
from typing import Any, Dict, List, Union

@dataclass
class DataCollatorSpeechSeq2SeqWithPadding:
    processor: Any

    def __call__(self, features: List[Dict[str, Union[List[int], torch.Tensor]]]) -> Dict[str, torch.Tensor]:
        # split inputs and labels since they have to be of different lengths and need different padding methods
        # first treat the audio inputs by simply returning torch tensors
        input_features = [{"input_features": feature["input_features"]} for feature in features]
        batch = self.processor.feature_extractor.pad(input_features, return_tensors="pt")

        # get the tokenized label sequences
        label_features = [{"input_ids": feature["labels"]} for feature in features]
        # pad the labels to max length
        labels_batch = self.processor.tokenizer.pad(label_features, return_tensors="pt")

        # replace padding with -100 to ignore loss correctly
        labels = labels_batch["input_ids"].masked_fill(labels_batch.attention_mask.ne(1), -100)

        # if bos token is appended in previous tokenization step,
        # cut bos token here as it's append later anyways
        if (labels[:, 0] == self.processor.tokenizer.bos_token_id).all().cpu().item():
            labels = labels[:, 1:]

        batch["labels"] = labels

        return batch
data_collator = DataCollatorSpeechSeq2SeqWithPadding(processor=processor)
import evaluate

metric = evaluate.load("wer")
# evaluate with the 'normalised' WER
do_normalize_eval = True

def compute_metrics(pred):
    pred_ids = pred.predictions
    label_ids = pred.label_ids

    # replace -100 with the pad_token_id
    label_ids[label_ids == -100] = processor.tokenizer.pad_token_id

    # we do not want to group tokens when computing the metrics
    pred_str = processor.tokenizer.batch_decode(pred_ids, skip_special_tokens=True)
    label_str = processor.tokenizer.batch_decode(label_ids, skip_special_tokens=True)

    if do_normalize_eval:
        pred_str = [normalizer(pred) for pred in pred_str]
        label_str = [normalizer(label) for label in label_str]
        # filtering step to only evaluate the samples that correspond to non-zero references:
        pred_str = [pred_str[i] for i in range(len(pred_str)) if len(label_str[i]) > 0]
        label_str = [label_str[i] for i in range(len(label_str)) if len(label_str[i]) > 0]

    wer = 100 * metric.compute(predictions=pred_str, references=label_str)

    return {"wer": wer}
model.config.forced_decoder_ids = None
model.config.suppress_tokens = []
model.config.use_cache = False
from transformers import Seq2SeqTrainingArguments

training_args = Seq2SeqTrainingArguments(
    output_dir="./",
    per_device_train_batch_size=8,
    gradient_accumulation_steps=8,  # increase by 2x for every 2x decrease in batch size
    learning_rate=1e-5,
    warmup_steps=100,
    max_steps=2500,
    gradient_checkpointing=True,
    fp16=True,
    evaluation_strategy="steps",
    per_device_eval_batch_size=4,
    predict_with_generate=True,
    generation_max_length=225,
    save_steps=2500,
    eval_steps=2500,
    logging_steps=1,
    report_to=["tensorboard"],
    load_best_model_at_end=True,
    metric_for_best_model="wer",
    greater_is_better=False,
    push_to_hub=True,
)
from transformers import TrainerCallback
from transformers.trainer_pt_utils import IterableDatasetShard
from torch.utils.data import IterableDataset

# trainer callback to reinitialise and reshuffle the streamable datasets at the beginning of each epoch
class ShuffleCallback(TrainerCallback):
    def on_epoch_begin(self, args, state, control, train_dataloader, **kwargs):
        if isinstance(train_dataloader.dataset, IterableDatasetShard):
            pass  # set_epoch() is handled by the Trainer
        elif isinstance(train_dataloader.dataset, IterableDataset):
            train_dataloader.dataset.set_epoch(train_dataloader.dataset._epoch + 1)
from transformers import Seq2SeqTrainer

trainer = Seq2SeqTrainer(
    args=training_args,
    model=model,
    train_dataset=vectorized_datasets["train"],
    eval_dataset=vectorized_datasets["test"],
    data_collator=data_collator,
    compute_metrics=compute_metrics,
    tokenizer=processor,
    callbacks=[ShuffleCallback()],
)
model.save_pretrained(training_args.output_dir)
processor.save_pretrained(training_args.output_dir)
trainer.train()
kwargs = {
    "dataset_tags": "mozilla-foundation/common_voice_11_0",
    "dataset": "common_voice_11_0",  # a 'pretty' name for the training dataset
    "language": "hy",
    "model_name": "Whisper Small hy",  # a 'pretty' name for your model
    "finetuned_from": "openai/whisper-large-v2",
    "tasks": "automatic-speech-recognition",
    "tags": "whisper-event",
}
trainer.push_to_hub(**kwargs)
