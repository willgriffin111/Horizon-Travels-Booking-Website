
function oneWay() {
    const returnElement = document.getElementById('return');
    const returnDateInput = document.querySelector('input[name="returnDate"]');
  
    if (document.getElementById('oneway').checked) {
      returnElement.style.display = 'none';
      returnDateInput.removeAttribute('required');
    } else {
      returnElement.style.display = 'table-cell';
      returnDateInput.setAttribute('required', '');
    }
  }


// function getarrivalcity(deptcity)    
// {
//         var req = new XMLHttpRequest();        
//         arrivalslist = document.getElementById('tobox');        
        
//         req.onreadystatechange = function(){
//             if (req.readyState == 4){
            
//                 if (req.status != 200){
//                 //error
//                 }
//                 else{
//                     var response = JSON.parse(req.responseText);                   
//                     //document.getElementById('myDiv').innerHTML = response.username
//                     var size = response.size;                   
//                     //alert(response.returncities[0]);
//                     for (var x=0; x < arrivalslist.length; x++){
//                         arrivalslist.remove(x);                        
//                     }
                    
//                     for (var i=0; i < size; i++){  

//                             arrivalslist.add(new Option(response.returncities[i], response.returncities[i]));    
//                     }
//                         // var option = document.createElement("Option");
//                         //option.text = response.returncities;
//                         //arrivalslist.add(option);
//                 }
//             }
//         }
//         req.open('GET', '/returncity/?q='+deptcity);
//         req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");   
//         req.send(); 
//         return false;
//     }

function getarrivalcity(deptcity) {
    var req = new XMLHttpRequest();        
    var arrivalslist = document.getElementById('tobox');        
        
    req.onreadystatechange = function() {
        if (req.readyState == 4) {
            if (req.status != 200) {
                //error
            } else {
                var response = JSON.parse(req.responseText);                   
                var size = response.size;
                arrivalslist.innerHTML = ""; // clear the select element
                for (var i = 0; i < size; i++) {
                    arrivalslist.add(new Option(response.returncities[i], response.returncities[i]));    
                }
            }
        }
    }
    req.open('GET', '/returncity/?q=' + deptcity);
    req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");   
    req.send(); 
    return false;
}


window.addEventListener( "pageshow", function ( event ) {
    var historyTraversal = event.persisted || 
                        ( typeof window.performance != "undefined" && 
                            window.performance.navigation.type === 2 );
    if ( historyTraversal ) {

        window.location.reload();
    } 
});



function setDateRange() {
    var today = new Date();
    var threeMonthsLater = new Date(today.getTime() + 90 * 24 * 60 * 60 * 1000);
    var formatDate = function(date) {
    return date.toISOString().split('T')[0];
    };
    var startDateInput = document.getElementById('outdate');
    var endDateInput = document.getElementById('returndate');

    document.getElementById("outdate").min = formatDate(today);
    document.getElementById("outdate").max = formatDate(threeMonthsLater);
    document.getElementById("returndate").min = formatDate(today);
    document.getElementById("returndate").max = formatDate(threeMonthsLater);

    

    endDateInput.min = startDateInput.value;
}


function bookingSetDateRange() {
    var today = new Date();
    var threeMonthsLater = new Date(today.getTime() + 90 * 24 * 60 * 60 * 1000);
    var formatDate = function(date) {
    return date.toISOString().split('T')[0];
    };

    document.getElementById("bookingDate").min = formatDate(today);
    document.getElementById("bookingDate").max = formatDate(threeMonthsLater);

}




function modifybooking() {
    
    if (document.getElementById('ModifyBooking').checked) {
        document.getElementById('modifyTable').style.display = 'table';
        // setRequired(false);
    } else {
        document.getElementById('modifyTable').style.display = 'none';
        // setRequired(true);
    }
}

function modifyJourneyTable(){
    selected = document.querySelector('input[name="travelId"]');  

    departLocation = document.querySelector('input[name="departLocation"]');  
    departTime = document.querySelector('input[name="departTime"]');  
    arrivalLocation = document.querySelector('input[name="arrivalLocation"]');  
    arrivalTime = document.querySelector('input[name="arrivalTime"]');  
    price = document.querySelector('input[name="price"]');  
    
    if (document.getElementById('deleteJourney').checked) {
        document.getElementById('insertTable').style.display = 'none';
        
        selected.setAttribute('required', '');

        departLocation.removeAttribute('required');
        departTime.removeAttribute('required');
        arrivalLocation.removeAttribute('required');
        arrivalTime.removeAttribute('required');
        price.removeAttribute('required');
        

    } else {
        document.getElementById('insertTable').style.display = 'table';
        
        
        departLocation.setAttribute('required', '');
        departTime.setAttribute('required', '');
        arrivalLocation.setAttribute('required', '');
        arrivalTime.setAttribute('required', '');
        price.setAttribute('required', '');
    }
    
    if (document.getElementById('modifyJourney').checked) {
        selected.setAttribute('required', '');
    }

}
function saveAsPDF() {
    // Get the HTML table element
    var table = document.getElementById("receiptTable");
  
    // Set the page size of the PDF document to match the size of the table
    var pdfWidth = table.offsetWidth-317;
    var pdfHeight = table.offsetHeight -50;
    var orientation = pdfWidth > pdfHeight ? 'l' : 'p'; // landscape or portrait
    var pdf = new jsPDF(orientation, 'pt', [pdfWidth, pdfHeight]);
  
    // Convert the table to a canvas element using html2canvas
    html2canvas(table).then(function(canvas) {
      // Add the canvas image to the PDF document
      var x = (pdf.internal.pageSize.width - pdfWidth) / 2;
      var y = (pdf.internal.pageSize.height - pdfHeight) / 2;
      pdf.addImage(canvas.toDataURL("image/png"), "PNG", x, y);
  
      // Save the PDF document
      pdf.save("booking.pdf");
    });
  }
  
function salesPerJourney() {
    var xhttp = new XMLHttpRequest(); // Create a new XMLHttpRequest object.

    month = document.getElementById('monthInput');
    travelType = document.getElementById('travelTypeSelect').value;

    xhttp.onreadystatechange = function() { // function that is called when the AJAX request is complete
        if (this.readyState == 4 && this.status == 200) {    // Check if the request was successful
            data = JSON.parse(xhttp.responseText);    // Convert the received response to a JSON array
            var ctx = document.getElementById("chart");
            var myLineChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data[1],
                    datasets: [{
                        data: data[0],
                        borderColor: 'white',
                        backgroundColor: 'darkgreen'
                    }]
                },
                options: {
                    responsive: true,
                    legend: {
                        display: false
                    },
                    title: {
                        display: true,
                        text: 'Sales per Journey',
                        fontColor: 'white'
                    },
                    scales: {
                        xAxes: [{
                            ticks: {
                                fontColor: "white"
                            },
                            scaleLabel: {
                                display: true,
                                labelString: 'Travel ID',
                                fontColor: "white"
                            },
                        }],
                        yAxes: [{
                            ticks: {
                                fontColor: "white"
                            },
                            scaleLabel: {
                                display: true,
                                labelString: 'Number of Sales',
                                fontColor: "white"
                            },
                        }]
                    }
                }
            });
        }
    };
    xhttp.open("GET", "/salesPerJourney?month=" + month.value + "&travelType=" + travelType, true);
    xhttp.send();
}




function salesPerYear() {
    var xhttp = new XMLHttpRequest(); // Create a new XMLHttpRequest object.

    year = document.getElementById('yearInput');
    

    xhttp.onreadystatechange = function() { // function that is called when the AJAX request is complete
        if (this.readyState == 4 && this.status == 200) {    // Check if the request was successful
            data = JSON.parse(xhttp.responseText);    // Convert the received response to a JSON array
            var ctx = document.getElementById("chart");
            var myLineChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data[1],
                    datasets: [{
                        data: data[0],
                        borderColor: 'black',
                        backgroundColor: 'darkgreen'
                    }]
                },
                options: {
                    responsive: true,
                    legend: {
                        display: false
                    },
                    title: {
                        display: true,
                        text: 'Sales per Year',
                        fontColor: 'white'
                    },
                    scales: {
                        xAxes: [{
                            ticks: {
                                fontColor: "white"
                            },
                            scaleLabel: {
                                display: true,
                                labelString: 'Month',
                                fontColor: "white"
                            },
                        }],
                        yAxes: [{
                            ticks: {
                                fontColor: "white"
                            },
                            scaleLabel: {
                                display: true,
                                labelString: 'Number of Sales',
                                fontColor: "white"
                            },
                        }]
                    }
                }
            });
        }
    };
    xhttp.open("GET", "/salesPerYear?year=" + year.value, true);
    xhttp.send();
}


