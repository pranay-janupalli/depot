// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>
sessionStorage.setItem("count",0)

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "detail" ,"productdescription" ,"cart"]
  static values = { url: String , count: Number}
  
  

  
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
  addToCart(event){
    // const metaCsrf = document.querySelector("meta[name='csrf-token']");
    // const csrfToken = metaCsrf.getAttribute('content');
    // var token = document.getElementsByName('csrf-token')[0].content
    // console.log(csrfToken)
    // const csrfToken = document.querySelector("[name='csrf-token']").content;

    
    const csrf = document.querySelector("[name='csrf-token']").getAttribute("content");
    
    
    var id1=event.target.id
    const data={product_id: id1}
    var url=this.urlValue
    
    
    fetch(url,
    {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrf,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data),
      credentials: "same-origin"
      
    }).then((response) => {if (response.status == 200 ) { this.countValue=this.countValue+1 ; this.cartTarget.textContent=this.countValue} 
                    else if(response.status == 404) 
                    { 
                      alert("url not found") 
                    }
                    else
                    {
                      alert("something went wrong")
                    }
                   })

    
    
    console.log(event.target)
    
    // .then((results) => results.text())
    // .then((x) => { document.getElementById("car").innerHTML=x})
    

    // Promise.all(promises)
    // .then((results) => results[1].text())
    // .then((x) => { document.getElementById("car").innerHTML=x})
    
    

    
  }
  showCart()
  {

    fetch('http://localhost:3000/carts/96').then((res)=>{ document.getElementById("car").innerHTML= res.text()})
  }
}
