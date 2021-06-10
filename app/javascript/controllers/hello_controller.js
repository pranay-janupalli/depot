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
    console.log(this.application)
    console.log(this.element)
    var details=this.detailTargets
    var one =""
    for (var i=0,len=details.length;i<len;i++)
    {
      one +=details[i].textContent;

    }
    
    var two=this.productdescriptionTarget.textContent;
    alert(one+two);
    // console.log(this.detailTargets)
    // document.getElementById("car").innerHTML=one+two;
    
  }
  loadCart() {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
        
        document.getElementById("cartshow").innerHTML=this.responseText;
      }
    };
    xhttp.open("GET", "http://localhost:3000/carts/93", true);
    xhttp.send();
  }
  addToCart(){
    // const metaCsrf = document.querySelector("meta[name='csrf-token']");
    // const csrfToken = metaCsrf.getAttribute('content');
    // var token = document.getElementsByName('csrf-token')[0].content
    // console.log(csrfToken)
    // const csrfToken = document.querySelector("[name='csrf-token']").content;
    
    const csrf = document.querySelector("[name='csrf-token']").getAttribute("content");
    
    
    var id1=(this.element.childNodes[1].id)
    const data={product_id: id1}
    
    
    fetch('http://localhost:3000/line_items',
    {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrf,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data),
      credentials: "same-origin"
      
    })
    .catch((error) => {
      console.log(error)
    });
    
  }
}
