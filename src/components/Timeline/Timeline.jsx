import React    from 'react';
import * as d3  from 'd3';
import * as d3Brush         from 'd3-brush';
import * as d3Time  from 'd3-time';
import * as d3Scale  from 'd3-scale';
import * as d3Select from 'd3-selection';

import Axis          from './Axis';
import AxisText          from './AxisText';
import Brush         from './Brush'
import TimeText         from './TimeText'

//Variables for the dimensioning the different elements of the timeline
const styles = {
  width : 800,
  height : 700,
  timelineHeight : 70,
  brushHeight : 30,
  padding : 30
};
//Define the timeline scale features
const scaleSetting = {
  orient : 'bottom',
  translate : 'translate(25, 30)',
  interval: [new Date(2013, 10, 11), new Date(2013, 10, 12)]
};
//Setting the brush
const brushSetting = {
  translate : 'translate(25, 0)',
  dateFunction : null
}
//Setting the time to display
const timeDisplay = {
  display: "00:00"
}
//Set up the timeline scale function
const timelineScale = (interval, w) => {
  return d3Scale.scaleTime()
          .domain([interval[0], interval[1]])
          .range([0, w]);
};
//Get the time back when moving or releasing the brush
const brushmove = () => {
  var s = d3Select.event.selection[0];
  var brushAction = "move";
  checkDate(s, brushAction)
}
const brushend = () => {
  var s = d3Select.event.selection[0];
  var brushAction = "end";
  checkDate(s, brushAction)
}
//Check and format the date selected with the brush
const checkDate = (d, b) => {
  var hr = parseInt(xScale.scale.invert(d).toString().slice(16,18), 10);
  var mn = parseInt(xScale.scale.invert(d).toString().slice(19,21), 10);
  mn > 45 ? hr++ : hr;
  if (mn >= 15 && mn <= 45) {
    mn = 30;
  } else {
    mn = 0
  }
  mn = dateFormat(mn)
  hr = dateFormat(hr)
  if(b === "end"){
    var t = hr + "_" + mn;
    return brushSetting.dateFunction(t);
  } else if(b === "move"){
    var t = hr + ":" + mn
    timeDisplay.display = t;
  }
}
const dateFormat = (d) => {
  if (d < 10) {
    d =  "0" + d.toString() + ""
  } else {
    d = d.toString()
  };
  return d
}
//Set up the brush function
const brush = ( w, h, f ) => {
  return d3Brush.brushX()
      .extent([[0, 0], [w, h]])
      .handleSize(0)
      .on("brush", brushmove)
      .on("end", brushend);
 }
//Initialise the timeline scale
const xScale = {
  scale : timelineScale(scaleSetting.interval, (styles.width-30))
};
//Initialise the brush
const timeBrush = {
  brush: brush(styles.width-30, styles.brushHeight, brushSetting.dateFunction)
}

export default class Timeline extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      isChanged: false,
      timeSlot: [new Date(2013, 10, 11, 0, 0), new Date(2013, 10, 11, 0, 30)],
      timeDisplay : "00:00"
    }
  }

  componentWillMount(){
    brushSetting.dateFunction = this.props.timeSelectionFunction
  }

  changeDisplay(t){
    this.setState({
      timeDisplay : t
    })
  }

  render(){
    return (
      <div className='container--timeline'>
        <svg className='timeline' width={styles.width} height={styles.timelineHeight}>
          <g className='timeline-element-container'>
            <Axis
              translate={scaleSetting.translate}
              orient={scaleSetting.orient}
              brushHeight={styles.brushHeight}
              scale={xScale.scale} />
            <AxisText
              translate={scaleSetting.translate}
              orient={scaleSetting.orient}
              brushHeight={styles.brushHeight}
              scale={xScale.scale} />
            <Brush
              brush={timeBrush.brush}
              translate={brushSetting.translate}
              scale={xScale.scale}
              timeSelected={this.props.timeSelected} />
          </g>
        </svg>
        <TimeText time = {timeDisplay.display} />
      </div>
    )

  }
}
