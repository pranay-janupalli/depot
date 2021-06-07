// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "detail" ,"productdescription"]

  
  greet(){
    // var nameStr=1;
    // alert(nameStr)
    // console.log(this.detailTarget)
    var details=this.detailTargets
    var one =""
    for (var i=0,len=details.length;i<len;i++)
    {
      one +=details[i].textContent;

    }
    
    var two=this.productdescriptionTarget.textContent;
    alert(one+two);
    // console.log(this.detailTargets)
    
  }
}
