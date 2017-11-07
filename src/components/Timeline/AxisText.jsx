import React    from 'react';
import d3       from 'd3';
var d3Scale =   require('d3-scale');
import * as d3Time  from 'd3-time';

export default class AxisText extends React.Component {
  componentDidMount(){
    this.renderAxis();
  }
  componentDidUpdate(){
    this.renderAxis();
  }
  renderAxis(){
    var node = this.refs.axis;
    var axis = d3.svg.axis().orient(this.props.orient).ticks(d3Time.timeHour.every(1)).scale(this.props.scale);
    d3.select(node).attr('class', 'axisText').call(axis);
    d3.select(".axisText").selectAll("text").style("font-size", "9px").attr("transform", "rotate(-45)").attr("x", "-17").attr("y", "-2");
  }

  render() {
      return <g className="axisText" ref="axis" transform={this.props.translate}></g>
  }
}
