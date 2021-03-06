﻿<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"+ request.getServerName() + ":" + request.getServerPort()+ path + "/";
%>
<!DOCTYPE html>
<meta charset ="utf-8">
<html>
  <head>
    <link rel="stylesheet" href="css/style.css" type="text/css"/>
	<link rel="stylesheet" href="css/pace-theme-center-circle.css"/>
    <script type="text/javascript" src="js/d3.v3.min.js"> </script>
	<script type="text/javascript" src="js/math.min.js"> </script>
	<script type="text/javascript" src="js/estimate.js"> </script>
	<script type="text/javascript" src="js/cutnames.js"> </script>
	<script type="text/javascript" src="js/highlight.js"> </script>
	<script type="text/javascript" src="js/ajax.js"> </script>
	<script type="text/javascript" src="js/papaparse.min.js"> </script>
	<script data-pace-options='{"ajax":true,"document":false,"eventLag":false}' type="text/javascript" src="js/pace.js"> </script>
  </head>
 <body>
 <h1>This is a heatmap example using d3.js</h1>
 <div id="chart" style="WHITE-SPACE:nowrap"></div>
 <div id="legend"></div>
 <ul id="menu"> 
  <li>excellent,keep the cluster</li> 
  <li>good but can be further improved</li> 
  <li>not good nor bad</li> 
  <li>bad,consider rebuilding the cluster</li>
  <li>terrible,must rebuild it</li>   
</ul>
 <defs>  
    <linearGradient id="myGradient" x1="0%" y1="0%" x2="100%" y2="0%">  
        <stop offset="0%" stop-color="#F00" />  
        <stop offset="100%" stop-color="#0FF" />  
    </linearGradient>  
 </defs> 
 <script type="text/javascript">
        var obj = ${data}
        obj =eval('('+obj.clusterData+')')
        //var data = new Array()
        var data = obj.data
        var names = obj.geneNames
		var array_data =[]
		var a= d3.rgb(0,255,0)
		var b= d3.rgb(255,0,0)
		var compute = d3.interpolate(a,b)
		//var matrixrow = 200
		//var matrixcol = 15
		var matrixrow = data.length
		var matrixcol = data[0].length
		for(var i=0;i<matrixrow;i++){
		    //data[i]= new Array();
			for(var j=0;j<matrixcol;j++){
			    ///data[i][j] = Math.floor(Math.random()*2-1)
				//temp = Math.floor(Math.random()*100)
				array_data[i*matrixrow+j] =data[i][j]
			}
		}
		var cur_rightblock =0//the block number mouse right clicked now
		
		
		var margin = { top: 0, right: 0, bottom: 0, left: 0 },
		  heatmapwidth = 600,
		  heatmapheight = 800,
		  width = heatmapwidth + margin.left + margin.right,        // ????????????Heatmap???
		  height = heatmapheight + margin.top + margin.bottom,
		  chart_width = 300,
		  gridSize = Math.floor(heatmapwidth / matrixcol),    // ???????????????width??24?
		  gridSize_h = Math.floor(heatmapheight / matrixrow),    // ???????????????width??24?
		  legendElementWidth = gridSize_h * 2,    // ????????????????}?
		  buckets = obj.dataCut.length,        // ??9?????
		  //colors = ["#ffffd9","#edf8b1","#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8","#253494","#081d58"];
		  colors =["#00CC33","#00CC66","#3366FF","#000099","#FFFF33","#CCCC99","#FF9933","#FF6666","#FF3333"]
		  
		  //get k non-duplicate random numbers
          /*var origin = new Array;
		  for(var i=0;i<heatmapheight;i++){
		      origin[i] = i+1
		  }
		  origin.sort(function(){//shuffle
			return 0.5 - Math.random() 
		  })
		  var cut = origin.slice(0,buckets)
	      var data_cut = new Array(buckets)
		  cut = cut.sort(function(a,b){
		    return a-b
		  })
		  for(var i=buckets-1;i>0;i--){
		    cut[i] = cut[i-1]
			data_cut[i] = Math.floor(cut[i] * matrixrow / heatmapheight)//change from pixel_height scale to data_size scale
		  }*/
		  //Below will be changed
		  /*var origin = new Array;
		  for(var i=0;i<matrixrow;i++){
			  origin[i] = i+1
		  }
		  origin.sort(function(){
			  return 0.5 - Math.random()
		  })
		  var data_cut = origin.slice(0,buckets)
		  data_cut = data_cut.sort(function(a,b){
			  return a-b
		  })*/
		  //Above will be changed,data_cut will be real
		  var data_cut = obj.dataCut
		  var cut = new Array(buckets)
		  for(var i =buckets-1;i>0;i--){
			  data_cut[i] = data_cut[i-1]
			  cut[i] = Math.floor(data_cut[i]* heatmapheight /matrixrow)
		  }
          
		  data_cut[0] =0 		  
 		  cut[0] =0
		  var cluster =new Array(data.length)
		  var row =0,inx = 0
		  while(row < data.length){
		     for(row=data_cut[inx];row<data_cut[inx+1];row++){
			     cluster[row] =inx
			 }
			 if(inx+1 < buckets -1){
			     inx++
			 }else{
			     for(row = data_cut[buckets-1];row < data.length;row++){
			         cluster[row] =buckets-1
			     } 
			 }
		  }
		  var est_obj = estimate(cluster,data)
		  var grouped_names = cutnames(data_cut,names,est_obj.group)
		  
		  
		  var tooltip = d3.select("body")
							 .append("div")
							 .attr("class","tooltip")
							 .style("opacity",0.0)
		  var linear = d3.scale.linear()
		    .domain([d3.min(array_data),d3.max(array_data)])
			.range([0,1])
		  /*var colorScale =d3.scale.quantile()
			.domain([d3.min(array_data),buckets-1,d3.max(array_data)])//???[0,n,?????]
			.range(colors)*///??
		  //??chart??svg
		 
		  var svg =d3.select("#chart").append("svg")
			 .attr("width",width)
			 .attr("height",height)
			 .append("g")//?svg?????g???????g??????
			 .attr("transform","translate("+margin.left+","+margin.top+")")
		  var date1 = new Date()
		  
		  var heatMap =svg.selectAll(".score")
		    .data(array_data)
			.enter()//?data?????????".score"
			.append("rect")
			.attr("x",function(d,i){return (i % matrixrow)*gridSize;})
			.attr("y",function(d,i){return parseInt(i / matrixrow)*gridSize_h;})
			.attr("rx",0)
			.attr("ry",0)
			.attr("class","hour bordered")
			.style("text-anchor", "end")
			.attr("width",gridSize)
			.attr("height",gridSize_h)
			.style("fill","#FFFFFF")
		 var date2 = new Date()
	     var duration = date2.getTime() -date1.getTime()
	     console.log("duration"+duration)
		 var tooltip = d3.select("body")
		 .append("div")
		 .attr("class","tooltip")
		 .style("opacity",0.0)
		 // duration(1000) ?1000ns????1s???????
		 heatMap.transition().duration(1)
		    //.style("fill",function(d){return colorScale(d);});
			.style("fill",function(d){return compute(linear(d));})
	     /* heatMap
		  .on("mouseover",function(d){
			 tooltip.html(d)
			 .style("left",(d3.event.pageX) +"px")
			 .style("top",(d3.event.pageY)+"px")
			 .style("opacity",1.0)
		  })*/
		  
		  var svg_block =d3.select("#chart").append("svg")
			 .attr("width", 50)
			 .attr("height",height)
			 .append("g")//?svg?????g???????g??????
			 .attr("transform","translate("+(margin.left+20)+","+0+")")
			  
         
		  var omenu=d3.select("#menu")
          .style("display","none")
		  .on("mouseout",function(d,i){
		     //omenu.style("display","none")
		  }); 
          omenu.selectAll("li")
		  .on("mouseover",function(d,i){d3.select(this).classed('active',true)})
          .on("click",function(d,i){
				   var cur_block = block.filter(function(data,index){return index==cur_rightblock})
				   cur_block.select("rect").style("fill",colors[i*2])
		      })
          .on("mouseout", function(d,i){d3.select(this).classed('active',false)})		  
		  //block on the right
		  var block = svg_block.selectAll(".block")
             // .data([0].concat(colorScale.quantiles()), function(d) { return d; });
             .data(cut)
          block.enter().append("g")
             .attr("class", "block");
          
          var block_rec =block.append("rect")
		    .attr("x", 0)
			//.attr("y", function(d, i) { return height /colors.length * i;})
			.attr("y",function(d,i){
				return d;
			})
            .attr("width", 25)
            //.attr("height", height/colors.length)
			.attr("height",function(d, i){
			     if(i<cut.length-1) return cut[i+1]-cut[i]
				 return height-cut[i]
			})
            .style("fill", function(d, i){
			     if(est_obj.group[i] >0.08){return colors[0]}
			     else if(est_obj.group[i] > 0.04){return colors[2]}
				 else if(est_obj.group[i] > 0.01){return colors[4]}
				 else if(est_obj.group[i] > -0.02){return colors[6]}
				 return colors[8]
				 })
		  //console.log(block_rec.attr("width"))
		  //bind block's listener		
			block_rec.on("mouseover",function(d,i){
			    edge_highlight(i)
			    rects.filter(function(data, inx) { return inx == i; }).attr("fill","grey");
				var xScale_line =d3.scale.linear()
                                    .domain(d3.extent(est_obj.sorted_points[i],function(d){return d.x}))
                                    .range([0,chart_width-padding.left-padding.right])
                var yScale_line =d3.scale.linear()
								   .domain([0,d3.max(est_obj.sorted_points[i],function(d){return d.y})*1.1])//multiple 1.1 in order show the entire curve
								   .range([height-padding.top-padding.bottom,0])
                var xAxis_line = d3.svg.axis()
							.scale(xScale_line)
							.orient('bottom');
						
				var yAxis_line = d3.svg.axis()
							.scale(yScale_line)
							.orient('left');
        
                svg_linechart.append("g")
						.attr("class","axis")
						.attr("transform","translate(" + padding.left + "," + (height-padding.bottom-padding.top) + ")")
						.call(xAxis_line)
                        .append("text")
						.text("Points within cluster")						
			    svg_linechart.append("g")
						.attr("class","axis")
						.attr("transform","translate(" + padding.left + "," + padding.top + ")")
						.call(yAxis_line)
						.append("text")
						.text("Distance to center")
                        //.selectAll("text")
						//.style("text-anchor", "end")
						//.attr("dx", ".30em")
						//.attr("dy", ".0em")
						//.attr("transform",function(d){return "rotate(-90)"})						
						
                var line =d3.svg.line()
                        .x(function(d){
						    return padding.left +xScale_line(d.x)
						})
                        .y(function(d){
						    return yScale_line(d.y)
						})
                        .interpolate('linear')
                svg_linechart.append('path')
                        .attr('class','line')				
						.attr('d',line(est_obj.sorted_points[i]))
				svg_linechart.selectAll('circle')
				        .data(est_obj.sorted_points[i])
						.enter()
						.append('circle')
			            .attr('cx',function(d){
						    return padding.left +xScale_line(d.x)
						})
						.attr('cy',function(d){
						    return yScale_line(d.y)
						})
						.attr('r',5)
					
		    })
			.on("mouseout",function(d,i){
			   svg_linechart.selectAll("g").remove()
			   svg_linechart.selectAll("path").remove()
			   svg_linechart.selectAll("circle").remove()
			   rects.filter(function(data,inx){return inx ==i;})
				   .transition()
				   .duration(500)
				   .attr("fill","steelblue");
			   svg_block.selectAll(".grey").remove()
			   svg.selectAll("line").remove()
			   //omenu.style("display","none")
			})
			.on("click",function(d,i){
			   
			   /*var url = "http://biit.cs.ut.ee/gprofiler/index.cgi?organism=scerevisiae&query=swi4+swi6+mbp1+mcm1+fkh1+fkh2+ndd1+swi5+ace2&r_chr=X&r_start=start&r_end=end&analytical=1&domain_size_type=annotated&term=&significant=1&sort_by_structure=1&user_thr=1.00&output=mini&prefix=ENTREZGENE_ACC"
			   var result;
			   getAJAX(function(data){
				   Papa.parse(data,{
					   //worker:true,
					   comments:"#INFO",
					   header:true,
					   step:function(row){
						   if(row.data[0]["t name"]){
							   console.log(row.data[0]["t name"] + row.data[0]["p-value"])
						   }
					   },
					   //fastMode:true,
					   complete:function(results){
						   result = results.data 
					   }
			   })
			   },url)*/		
		
			   var genes =grouped_names[i].join(",")
			  
			   tooltip.html(genes)
				 .style("left",(d3.event.pageX) +"px")
				 .style("top",(d3.event.pageY)+"px")
				 .style("width",(genes.length*8)+"px")
				 .style("opacity",1.0)
			   
			})
			.on("contextmenu", function(data, index) {
			   //handle right click
			   var menu =document.getElementById("menu")
			   menu.removeChild(menu.childNodes[0])
			   menu.insertAdjacentHTML("afterBegin","<h>The sihoute coefficient for this cluster is : "+est_obj.group[index]+",how do you like this cluster?</h>")
			   omenu
			   .style("display","block")
			   .style("left",(d3.event.pageX) +"px")
			   .style("top",(d3.event.pageY)+"px")
			   cur_rightblock = index
			   d3.event.preventDefault()
			});
          block.exit().remove();
		  for(var i=buckets-1;i>0;i--){
			  svg_block.append("line")
					.attr("x1",0)
					.attr("y1",cut[i])				
					.attr("x2",25)
					.attr("y2",cut[i])
					.attr("stroke","white")
					.attr("stroke-width",2)
		  }
		  /*block.append("text")
            .attr("class", "mono")
            .text(function(d,i) { return "label:" + i; })
            .attr("x", 80)
            //.attr("y", function(d, i) { return height /colors.length * i ;})
			.attr("y",function(d,i){
			    return d
			})
            .style("writing-mode","tb-rl")*/
          
			
		 // draw charts of sihoute coefficient for all clusters
		 var svg_chart =d3.select("#chart").append("svg")
			 .attr("width", chart_width)
			 .attr("height",height )
			 .append("g")//?svg?????g???????g??????
			 .attr("transform","translate("+(margin.left+20)+","+0+")")
		 var padding ={left:50,right:30,top:20,bottom:20}
		 var xScale =d3.scale.ordinal()
                       .domain(d3.range(est_obj.group.length))
                       .rangeRoundBands([0,chart_width-padding.left-padding.right])
         var yScale =d3.scale.linear()
                       //.domain([d3.min(est_obj.group),d3.max(est_obj.group)])
                       .domain([0,d3.max(est_obj.group)])
                       .range([height-padding.top-padding.bottom,0])					   
	     var xAxis =d3.svg.axis()
                      .scale(xScale)
                      .orient("bottom")
         var yAxis =d3.svg.axis()
                      .scale(yScale)
                      .orient("left")
		 var rectPadding =4

		 var rects = svg_chart.selectAll(".MyRect")
		              .data(est_obj.group)
					  .enter()
					  .append("rect")
					  .attr("class","MyRect")
					  .attr("transform","translate("+padding.left+","+padding.top+")")
					  .attr("x",function(d,i){
					      return xScale(i) + rectPadding /2
					  })
					  .attr("y",function(d,i){
					      return yScale(d)
					  })
					  .attr("width", xScale.rangeBand() - rectPadding )
					  .attr("height", function(d){
						  return height - padding.top - padding.bottom - yScale(d);
					  })
					  .attr("fill","steelblue")        //?????????????CSS??
					  .on("mouseover",function(d,i){
						  d3.select(this)
							.attr("fill","grey");
						  edge_highlight(i)
					    })
					 .on("mouseout",function(d,i){
						  d3.select(this)
							.transition()
							.duration(500)
							.attr("fill","steelblue");
						  svg_block.selectAll(".grey").remove()
			              svg.selectAll("line").remove()
						})
						
         /*var texts = svg_chart.selectAll(".MyText")
			.data(est_obj.group)
			.enter()
			.append("text")
			.attr("class","MyText")
			.attr("transform","translate(" + padding.left + "," + padding.top + ")")
			.attr("x", function(d,i){
				return xScale(i) + rectPadding/2;
			})
			.attr("y",function(d){
				return yScale(d);
			})
			.attr("dx",function(){
				return (xScale.rangeBand() - rectPadding)/2;
			})
			.attr("dy",function(d){
				return 20;
			})
			.text(function(d){
				return d;
			});*/
		 svg_chart.append("g")
		    .attr("class","axis")
			.attr("transform","translate(" + padding.left + "," + (height -padding.bottom) + ")")
            .call(xAxis)
			.append("text")
			.text("Cluster Id"); 
    	 svg_chart.append("g")
		    .attr("class","axis")
            .attr("transform","translate(" + padding.left + "," + padding.top + ")")
            .call(yAxis)
			.append("text")
		    .text("Sihoutte Coefficient");
			
	  //draw line chart for certain cluster
         var svg_linechart =d3.select("#chart").append("svg")
			 .attr("width", chart_width)
			 .attr("height",height)
		 	 .attr("transform","translate("+(margin.left+20)+","+0+")")
			
      //???legend
		 var svg_legend =d3.select("#legend").append("svg")
			 .attr("width", 1000)
			 .attr("height",80)
			 .attr("x",50)
			 .attr("y", heatmapheight)
		  var defs =svg_block.append("defs")
		  var linearGradient = defs.append("linearGradient")  
                        .attr("id","linearColor")  
                        .attr("x1","0%")  
                        .attr("y1","0%")  
                        .attr("x2","100%")  
                        .attr("y2","0%");  
  
          var stop1 = linearGradient.append("stop")  
                .attr("offset","0%")  
                .style("stop-color",a.toString());  
  
		  var stop2 = linearGradient.append("stop")  
                .attr("offset","100%")  
                .style("stop-color",b.toString());
		  var colorRect = svg_legend.append("rect")
                .attr("x", 70)  
                .attr("y", 0)  
                .attr("width", 200)  
                .attr("height", 30)  
                .style("fill","url(#" + linearGradient.attr("id") + ")"); 
          var text_small =svg_legend.append("text")
                .text("small")
                .attr("x",70)
				.attr("y",60)
		  var text_large =svg_legend.append("text")
                .text("large")
                .attr("x",220)
				.attr("y",60)
		  for(var i =0;i<5;i++){
			   svg_legend.append("rect")
					.attr("x", 300+i*70)  
					.attr("y", 0)  
					.attr("width", 20)  
					.attr("height", 30)  
					.style("fill",colors[i*2])			
		  }
		  var comments=["exellent","good","ok","bad","terrible"]
		  for(var i=0;i<5;i++){
		       svg_legend.append("text")
			        .text(comments[i])
                    .attr("x",300+i*70)
                    .attr("y",60)					
		  }
         d3.select("body").on("click",function(d,i){
		      omenu.style("display","none")
		 })
 </script>
 </body>
 </html>