import './assets/styles/global.css';
import React from 'react';
import ReactDOM from 'react-dom';
//import InteractiveMap from './components/DensityMap/interactiveMap.jsx';
import App from './components/App.jsx'


const mountingPoint = document.createElement('div');
mountingPoint.className = 'react-app';
document.body.appendChild(mountingPoint);
ReactDOM.render(< App />, mountingPoint);
