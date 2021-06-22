Rails.configuration.stripe = {
    :publishable_key => Rails.application.credentials.stripe[:development][:publishable_key],
    :secret_key      => Rails.application.credentials.stripe[:development][:secret_key]
  }

Stripe.api_key = Rails.configuration.stripe[:secret_key]