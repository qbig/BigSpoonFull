var chartdata = [];

if (dataIsNotLoaded()){
	console.log("ERROR: Initialize the 'chartdata' variable before this script.");
	while (dataIsNotLoaded()){
		//doNothing
	}
}

if (chartIsNotCreated()){
	console.log("ERROR: Create the 'reportchart' dom object before this script.");
	while (chartIsNotCreated()){
		//doNothing
	}
}

Time.firstDayOfWeek = 1;
var currTime = new Time();
//currTime.firstDayOfWeek = 1;
var currWeek = currTime.weekOfCurrentMonth();
function getTimeYMD(timeObj){
	var date = timeObj.date;
	return {"y":date.getFullYear(), "m":date.getMonth()+1, "d":date.getDate() };
}
function getMonthStr(monthNum){
	if(1<=monthNum && monthNum<=12){
		var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
		return months[monthNum-1];
	}
}

function plotChart(){
	var chartSpending = document.getElementById("chart-spending");
	var chartTOTime = document.getElementById("chart-totime");

	var chartDates = getChartDates("weeks");
	var datePeriods = chartDates.periods;
	var chartLabels = chartDates.labels;
	var chartData = [];
	var lineChartData = {
		labels : ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5"],
		datasets : [
			{
				fillColor : "rgba(220,220,220,0.5)",
				strokeColor : "rgba(220,220,220,1)",
				pointColor : "rgba(220,220,220,1)",
				pointStrokeColor : "#fff",
				data : [65,59,90,81,56,55,40]
			}
			// ,
			// {
			// 	fillColor : "rgba(151,187,205,0.5)",
			// 	strokeColor : "rgba(151,187,205,1)",
			// 	pointColor : "rgba(151,187,205,1)",
			// 	pointStrokeColor : "#fff",
			// 	data : [28,48,40,19,96,27,100]
			// }
		]
		
	}

	for (var i=0; i<datePeriods.length; ++i){
		//var getData = $.post("python", );
	}
	//var myLine = new Chart(chartSpending.getContext("2d")).Line(lineChartData);

}
function getChartDates(periodInterval){
  switch (true){
  case /^month$/.test(periodInterval):
    break;
  case /^week$/.test(periodInterval):
    return getChartWeekLabels(); break;
  }
}
function updateChartPlot(chartCanvas, lineChartData){
	var myLine = new Chart(chartCanvas.getContext("2d")).Line(lineChartData);
}


function Period(fromDateStr, toDateStr){
	return {"from_date":fromDateStr, "to_date":toDateStr};
}

function getChartWeekLabels(){ //function weekLabels(){ // weekLabels(currTimeObj, currWeek)
	var currTimeObj = new Time();
	var currWeek = currTimeObj.weekOfCurrentMonth();

	var YMD = getTimeYMD(currTimeObj);
	var focusDate = new Time(YMD.y, YMD.m, YMD.d);
	var numWeeksThisMonth = focusDate.weeksInMonth();

	var numWeeks = 0;
	var firstDisplayWeek = null;
	//If not the last week of the month, need to show weeks from previous month.
	if (currWeek<numWeeksThisMonth){
		focusDate.advanceMonths(-1);
		//Don't get .weeksInMonth() from .advanceMonths(-1).beginningOfWeek()
		//Bad example: Today is Friday, 1 Nov. One month back is Tuesday, 1 Oct.
		//First day of week would be Monday, 30 Sept. Number of weeks in that first day, would belong to Sept, not Oct.
		numWeeks = focusDate.weeksInMonth(); //numWeeksLastMonth
		focusDate.beginningOfWeek();
		firstDisplayWeek = focusDate;
	}
	else {
		focusDate.beginningOfMonth();
		numWeeks = numWeeksThisMonth;
		focusDate.beginningOfWeek();
		firstDisplayWeek = focusDate;
	}

	var labels = [];
	var periods = [];
	for(var i=0+1; i<numWeeks+1; ++i){ 
		var weeknum = (currWeek+i)%numWeeks;
		weeknum = (weeknum==0)? numWeeks : weeknum;
		var currYMD = getTimeYMD(focusDate);
		labels.push("Week "+weeknum+": "+currYMD.d+" "+getMonthStr(currYMD.m));
		focusDate.advanceDays(7); //the ++ for the week in Time Object.
	}
	return {"labels":labels, "periods":""}
}


	
	







//===========================================================================

function dataIsNotLoaded(){
	return (typeof chartdata =='undefined');
}

function chartIsNotCreated(){
	return (document.getElementsByClassName("reportchart").length < 1);
}




