class PanZoomMap extends PanZoomPage {
  
  public PanZoomMap() {
    minLatitude = 32.57816;
    maxLatitude = 41.75613;
    minLongitude = -124.20347;
    maxLongitude = -115.48307;
    
    mapScale = 1;
    mapTranslateX = 0;
    mapTranslateY = 0;
    
    fitMapOnPage();
  }
  
  void fitMapOnPage() {
    float deltaLat = maxLatitude - minLatitude;
    float deltaLong = maxLongitude - minLongitude;
    if (deltaLong >= deltaLat) {
      mapScale = 1.0 / deltaLong;
      mapTranslateX = 0;
      mapTranslateY = (1.0 - deltaLat * mapScale) / 2.0;
    }
    else {
      mapScale = 1.0 / deltaLat;
      mapTranslateY = 0;
      mapTranslateX = (1.0 - deltaLong * mapScale) / 2.0;      
    }
  }
  
  float longitudeToPageX(float longitude) {
    float relativeLong = longitude - minLongitude;
    return relativeLong * mapScale + mapTranslateX;
  }
  
  float latitudeToPageY(float latitude) {
    float relativeLat = latitude - minLatitude;
    return 1.0 - (relativeLat * mapScale + mapTranslateY);
  }
  
  float mapLengthToPageLength(float mapLen) {
    return mapLen * mapScale;
  }
  
  float pageXtoLongitude(float pageX) {
    return (pageX - mapTranslateX) / mapScale + minLongitude;
  }
  
  float pageYtoLatitude(float pageY) {
    return (1.0 - pageY - mapTranslateY) / mapScale + minLatitude;
  }
  
  float pageLengthToMapLength(float pageLen) {
    return pageLen / mapScale;
  }
  
  
  float longitudeToScreenX(float longitude) {
    float pageX = longitudeToPageX(longitude);
    return pageXtoScreenX(pageX);
  }
  
  float latitudeToScreenY(float latitude) {
    float pageY = latitudeToPageY(latitude);
    return pageYtoScreenY(pageY);
  }
  
  float mapLengthToScreenLength(float mapLen) {
    float pageLen = mapLengthToPageLength(mapLen);
    return pageLengthToScreenLength(pageLen); 
  }
  
  
  float screenXtoLongitude(float screenX) {
    float pageX = screenXtoPageX(screenX);
    return pageXtoLongitude(pageX);
  }
  
  float screenYtoLatitude(float screenY) {
    float pageY = screenYtoPageY(screenY);
    return pageYtoLatitude(pageY);
  }
  
  float screenLengthToMapLength(float screenLen) {
    float pageLen = screenLengthToPageLength(screenLen);
    return pageLengthToMapLength(pageLen); 
  }
  
  float mapScale;
  float mapTranslateX;
  float mapTranslateY;
  
  float minLatitude;
  float maxLatitude;
  float minLongitude;
  float maxLongitude;
}