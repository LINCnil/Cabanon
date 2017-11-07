import React    from 'react';



export default class TimeText extends React.Component {
  constructor(props){
    super(props)
  }

  render(){
    return (
      <div className='timeText'><h3>{this.props.time}</h3></div>
    )
  }
}
