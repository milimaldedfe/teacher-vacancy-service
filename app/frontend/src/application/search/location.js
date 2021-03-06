import { enableRadiusSelect, disableRadiusSelect } from './radius';

export const onChange = (value) => {
  if (/\d/.test(value)) {
    enableRadiusSelect();
  } else {
    disableRadiusSelect();
  }
};

export const getCoords = () => {
  if (document.querySelector('#location-field').dataset.coordinates) {
    return document.querySelector('#location-field').dataset.coordinates.split(' ').join(',');
  }
  return false;
};
