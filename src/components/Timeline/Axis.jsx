import React    from 'react';
import d3       from 'd3';
var d3Scale =   require('d3-scale');
import * as d3Time  from 'd3-time';

export default class Axis extends React.Component {
  componentDidMount(){
    this.renderAxis();
  }
  componentDidUpdate(){
    this.renderAxis();
  }
  renderAxis(){
    var node = this.refs.axis;
    var axis = d3.svg.axis().orient(this.props.orient).ticks(d3Time.timeMinute.every(30)).tickSize(-this.props.brushHeight).scale(this.props.scale);
    d3.select(node).attr('class', 'axis').call(axis);
    d3.select(".axis").selectAll("text").remove();
  }

  render() {
      return <g className="axis" ref="axis" transform={this.props.translate}></g>
  }
}
