import React          from 'react';
import d3             from 'd3';

var d3Queue =         require ('d3-queue');
var topojson =        require ('topojson');
var d3Geo =           require ('d3-geo');
var d3Scale =         require('d3-scale');
var d3Chromatic =     require('d3-scale-chromatic')

import InfoViz        from './Legend/InfoViz';
import ChloroMap      from './Map/ChloroMap';
import DotMap         from './Map/DotMap';

const styles = {
  width : 600,
  height : 700,
  padding : 10
};

export default class ViZContainer extends React.Component {
  constructor(props) {
    super(props)
    //Set up the map projection
    this.projection = d3Geo.geoAlbers()
                        .center([0,40.73])
                        .rotate([73.87, 0])
                        .parallels([50, 60])
                        .scale(110000);
    //Set up the path generator
    this.path = d3Geo.geoPath()
                  .projection(this.projection)
    //Set up the color scale
    this.color = d3Scale.scaleThreshold()
                        .range(["#000000", "#000419", "#00072c", "#00145b", "#002496", "#0033c8", "#225aff"]);
    //Setting up the state for the visualisation
    //'isAno' is used to determine which map to display
    //'date' defines which time of a dataset should be displayed
    //'dataset' corresponds to the identifier of the dataset selected ('AD', 'UD', 'NYCOD')
    //'nycTopoJson' corresponds to the geographic data needed to draw the map
    //'data' is the actual data fed into the visualisation
    //'link' is a by-product of the loaded anonymised dataset to bundle the connected zcta
    //'projection' corrresponds to the map projection
    //'path' corresponds to the drawing paths
    //'color' corresponds to the color scale
    this.state = {
      isAno: true,
      date: this.props.date,
      dataset: this.props.dataset,
      nycTopoJson: null,
      data : null,
      link : null,
      projection : this.projection,
      path: this.path,
      color : this.color
    }
  }
  //Default state and data (geo data and G29 anonymised dataset at midnight)
  componentWillMount(){
    d3Queue.queue()
      .defer(d3.json, "public/data/toponyc.json")
      .defer(d3.csv, "public/data/AD/time_00_00.csv")
      .defer(d3.csv, "public/data/AD/zctaLink_00_00.csv")
      .await((error, nyc, data, link) => {
        this.updateData(nyc, data, "AD", link);
      })
  }
  //Update of the state with the new dataset
  componentWillReceiveProps(newProps){
    if (newProps.date == null || newProps.dataset == null) {
      console.log("Error No New Props Date or Dataset")
    } else {
      if(newProps.dataset == "AD" || newProps.dataset == "UD"){
        d3Queue.queue()
        .defer(d3.csv, "public/data/" + newProps.dataset + "/time_" + newProps.date + ".csv")
        .defer(d3.csv, "public/data/" + newProps.dataset + "/zctaLink_" + newProps.date + ".csv")
        .await((error, data, link) => {
          this.updateData(null, data, newProps.dataset, link);
          this.setState({
            dataset: newProps.dataset
          });
        })
      } else {
        d3Queue.queue()
        .defer(d3.csv, "public/data/" + newProps.dataset + "/time_" + newProps.date + ".csv")
        .await((error, data, link) => {
          this.updateData(null, data, newProps.dataset, null);
          this.setState({
            dataset: newProps.dataset
          });
        })
      }
    }
  }
  //Check and parse the data to store in the state
  updateData(g, data, dataset, link){
    //If data are received format and check them
    if(data !== null){
      //Format and check datatype for the anonymised datasets
      if(dataset === "AD" || dataset == "UD"){
        var revisedAno = data.map((d) => ({
          zcta : d.zcta,
          taxis : parseInt(d.taxis)
        }))
        //Check the highest number of taxis in all ZCTA and apply the color scale to the dataset
        var m = d3.max(_.map(revisedAno, 'taxis'))
        var i = [0, 1, Math.round(((m-1)/4)+1), Math.round(((m-1)/5)*2+1), Math.round(((m-1)/5)*3+1), Math.round(((m-1)/5)*4+1), m]
        this.state.color.domain(i)
        //Create an object for each ZCTA presents in the dataset and associates to it objects of connected ZCTA
        var linkAno = d3.nest()
                      .key(function(d){return d.zcta_pickup}).sortKeys(d3.ascending)
                      .key(function(d){return d.zcta_dropoff}).sortKeys(d3.ascending)
                      .map(link);
        var linkClean = []
        //For each object (ZCTA) of linkAno count the number of taxis going in the associated objects (ZCTA)
        linkAno = _.forEach(linkAno, function(value, key){
          var valueArray = [];
          _.forEach(value, function(value, key){
            var valueObj = {
              zcta: key,
              occurence: value.length
            }
            valueArray.push(valueObj)
          });
          var zctaValue = {
            zcta : key,
            link : valueArray
          }
          linkClean.push(zctaValue)
        })
        //Update the state
        this.setState({
          isAno: true,
          data : revisedAno,
          link : linkClean
        });
      }
      //Format and check datatype for the raw dataset
      else if(dataset == "NYCOD") {
        var topoCabs = data.map((d) => ({
              type: "Point",
              coordinates: [parseFloat(d.longitude),parseFloat(d.latitude)],
              id : d.taxis,
              properties: {}
        }))
        this.setState({
          isAno: false,
          data : {
            type: "FeatureCollection",
            features: topoCabs
          }
        })
      }
      //Set the geodata
      if(g !== null) {
        this.setState({
          nycTopoJson: g
        })
      }
    }
    //If no data received, send message
    else {
      console.log('No data')
    }
  }

  render(){
    const isAno = this.state.isAno;
    var map = null;
    //Determine which map will be displayed based on the state ('isAno')
    if(isAno){
      map = <ChloroMap
        nycTopoJson={this.state.nycTopoJson}

        width={styles.width}
        height={styles.height}

        data={this.state.data}
        link={this.state.link}

        projection = {this.state.projection}
        path = {this.state.path}
        color = {this.state.color}
      />
    } else {
      map = <DotMap
        nycTopoJson={this.state.nycTopoJson}

        width={styles.width}
        height={styles.height}

        data={this.state.data}

        projection = {this.state.projection}
        path = {this.state.path}
      />
    }

    return (
      <div className='viz-container'>
        <InfoViz color={this.state.color} selectData={this.props.selectData} />
        <div className='map' id='map'>
          <svg width={styles.width} height ={styles.height} className="map-svg">
            {map}
          </svg>
        </div>
      </div>
    )
  }
}
