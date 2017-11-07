import React    from 'react';
import * as d3  from 'd3';

import InfoDescription      from './Description';
import InfoLegend from './Legend';
import ToggleData from './ToggleData';
import InfoCredits from './Credits';

export default class InfoViz extends React.Component {
  constructor (props) {
    super(props)

  }
  //Render the left info elements 
  render(){
    return (
        <div className="info-insert">
          <InfoDescription />
          <InfoLegend color={this.props.color} />
          <ToggleData selectData={this.props.selectData} />
          <InfoCredits />
      </div>
    )
  }
}
