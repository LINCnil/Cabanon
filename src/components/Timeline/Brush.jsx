import React                from 'react';
import d3                   from 'd3';
import * as d3Brush         from 'd3-brush';
import * as d3Dispatch      from 'd3-dispatch';
import * as d3Drag          from 'd3-drag';
import * as d3Interpolate   from 'd3-interpolate';
import * as d3Select        from 'd3-selection';
import * as d3Scale         from 'd3-scale';
import * as d3Transition    from 'd3-transition';

export default class Brush extends React.Component {
  constructor(props){
    super(props);
  }

  componentDidMount(){
    this.renderBrush();
  }

  shouldComponentUpdate(){
    return true;
  }

  componentDidUpdate(){
    this.setBrushPosition(this.props.timeSelected)
  }

  renderBrush(){
    var node = d3Select.select('.brush'),
    brush = this.props.brush;
    var gBrush = node.attr("class", "brush")
        .call(brush)
        .call(brush.move, [new Date(2013, 10, 11, 0, 0), new Date(2013, 10, 11, 0, 30)].map(this.props.scale));
  }

  setBrushPosition(t){
    const hourSelected = parseFloat(t.slice(0,2));
    const minuteSelected = parseFloat(t.slice(3,5));
    const dateSelected = new Date(2013, 10, 11, hourSelected, minuteSelected);
    var brush = this.props.brush;
    d3.selectAll(".selection").attr("x", this.props.scale(dateSelected))
  }

  render() {
    return <g className="brush" ref="brush" transform="translate(25,0)"></g>
  }
}
