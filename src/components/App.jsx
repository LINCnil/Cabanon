import React from 'react';
import * as d3Select from 'd3-selection';


import ViZContainer from './Viz/VizContainer';
// import Menu from './Menu/Menu';
import Timeline from './Timeline/Timeline';

export default class IxtMap extends React.Component{

  constructor(props){
    super(props)
    //Setting the state to launch the default data.
    //The state is updated when using the timeline - brushend() - and the left menu - toggleData() -
    this.state = {
      selectedDate : "00_00",
      dataset: "AD",
    }
  }
  //Update of the state with the new date selected using the timeline
  //Passed to the brush function (const timeBrush in Timeline.jsx) and is called on brushend()
  //When called, the function returns the date selected on the timeline
  brushend(d){
    if ( d !== this.state.selectedDate) {
      this.setState({
        selectedDate: d
      })
    }
  }
  //Update of the state with the selected dataset in the left menu
  //The function is called when an data selection item (see ToggleItem.jsx) is clicked
  //When called, the function returns the id of the item clicked
  toggleData(n){
    if(n !== this.state.dataset){
      this.setState({
        dataset: n
      })
    }
  }
  //Render the app
  render(){
    return (
      <div>
        {/* <Menu /> */}
        <div className="viz-container">
          <ViZContainer date={this.state.selectedDate} dataset={this.state.dataset} selectData={this.toggleData.bind(this)} />
          <div className="separator"></div>
        </div>
        <Timeline timeSelectionFunction = {this.brushend.bind(this)} timeSelected={this.state.selectedDate}  />
      </div>
    )
  }
}
