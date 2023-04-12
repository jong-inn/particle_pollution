import java.lang.Exception;

class DataManipulation {
    String localSiteName, type, locationShownName;
    float latitude, longitude;
    float screenX, screenY;
    float pm25, pm25Normalized;
    float windSpeed, windSpeedNormalized, rotationSpeed;
    float windDirection;
    float radius;
    color lerpColor;
    String date;

    float minPm25 = 0.0;
    float maxPm25 = 20.0;
    float minRadius = 3.0;
    float maxRadius = 10.0;

    float minWindSpeed = 0.0;
    float maxWindSpeed = 10.0;
    float minRotationSpeed = 0.0;
    float maxRotationSpeed = 1.0;

    color lowestPm25Color = color(255, 131, 0); // Orange
    color highestPm25Color = color(139, 0, 0); // Dark Red

    public DataManipulation(TableRow row, PanZoomMap panZoomMap, String type) {
        this.type = type;
        if (type.equals("location")) {
            fitLocation(row, panZoomMap);
        } else if (type.equals("pm25")) {
            fitPm25(row, panZoomMap);
        } else if (type.equals("wind")) {
            fitWind(row, panZoomMap);
        }
    }

    public DataManipulation(){
    }

    void fitLocation(TableRow row, PanZoomMap panZoomMap) {
        this.localSiteName = row.getString("Local Site Name");
        this.latitude = row.getFloat("Latitude");
        this.longitude = row.getFloat("Longitude");
        this.locationShownName = row.getString("Location Shown");
        this.screenX = panZoomMap.longitudeToScreenX(longitude);
        this.screenY = panZoomMap.latitudeToScreenY(latitude);
    }

    void fitPm25(TableRow row, PanZoomMap panZoomMap) {
        this.localSiteName = row.getString("Local Site Name");
        this.latitude = row.getFloat("Latitude");
        this.longitude = row.getFloat("Longitude");
        this.locationShownName = row.getString("Location Shown");
        try {
            this.date = row.getString("Date Local");
        } catch (Exception e) {
            this.date = "";
        }
        this.screenX = panZoomMap.longitudeToScreenX(longitude);
        this.screenY = panZoomMap.latitudeToScreenY(latitude);
        try {
            this.pm25 = row.getFloat("Arithmetic Mean");
        } catch (Exception e) {
            this.pm25 = row.getFloat("PM25 Average");
        }
        if (pm25 < minPm25) {
            this.pm25Normalized = 0.0;
            this.pm25 = minPm25;
        } else if (pm25 > maxPm25) {
            this.pm25Normalized = 1.0;
        } else {
            this.pm25Normalized = (pm25 - minPm25) / (maxPm25 - minPm25);
        }
        this.radius = lerp(minRadius, maxRadius, pm25Normalized);
        this.lerpColor = lerpColorLab(lowestPm25Color, highestPm25Color, pm25Normalized);
    }

    void fitWind(TableRow row, PanZoomMap panZoomMap) {
        this.localSiteName = row.getString("Local Site Name");
        this.latitude = row.getFloat("Latitude");
        this.longitude = row.getFloat("Longitude");
        this.locationShownName = row.getString("Location Shown");
        try {
            this.date = row.getString("Date Local");
        } catch (Exception e) {
            this.date = "";
        }
        this.screenX = panZoomMap.longitudeToScreenX(longitude);
        this.screenY = panZoomMap.latitudeToScreenY(latitude);
        try {
            this.windDirection = row.getFloat("Arithmetic Mean Direction");
        } catch (Exception e) {
            this.windDirection = row.getFloat("Wind Direction Average");
        }
        try {
            this.windSpeed = row.getFloat("Arithmetic Mean Speed");
        } catch (Exception e) {
            this.windSpeed = row.getFloat("Wind Value Average");
        }
        if (windSpeed < minWindSpeed) {
            this.windSpeedNormalized = 0.0;
            this.windSpeed = minWindSpeed;
        } else if (windSpeed > maxWindSpeed) {
            this.windSpeedNormalized = 1.0;
        } else {
            this.windSpeedNormalized = (windSpeed - minWindSpeed) / (maxWindSpeed - minWindSpeed);
        }
        this.rotationSpeed = lerp(minRotationSpeed, maxRotationSpeed, windSpeedNormalized);
    }
 
    color lerpColorLab(color c1, color c2, float amt) {
        // convert input colors to Lab space
        float[] lab1 = colorToLab(c1);
        float[] lab2 = colorToLab(c2);
        
        // linearly interpolate the three L, a, b parmeters to find the in-between color
        // in Lab space
        float[] labNew = new float[3];
        labNew[0] = lerp(lab1[0], lab2[0], amt);
        labNew[1] = lerp(lab1[1], lab2[1], amt);
        labNew[2] = lerp(lab1[2], lab2[2], amt);
        
        // convert this Lab color back into a regular rgb color for drawing on the screen
        color c = labToColor(labNew);
        return c;
    }

    // converts a color stored in processing's built-in color type to its Lab representation
    float[] colorToLab(color c) {
        pushStyle();
        colorMode(RGB, 1, 1, 1);
        float[] rgb01 = { red(c), green(c), blue(c) };
        float[] lab = rgb01ToLab(rgb01); 
        popStyle();
        return lab;
    }

    // converts a color defined in Lab space to rgb space and returns the result as a Processing color
    color labToColor(float[] lab) {
        float[] rgb01 = labToRgb01(lab);    
        pushStyle();
        colorMode(RGB, 1, 1, 1);
        color c = color(rgb01[0], rgb01[1], rgb01[2]);
        popStyle();
        return c;
    }

    float[] labToRgb01(float[] lab) {
        double y = (lab[0] + 16.0f) / 116.0f;
        double x = lab[1] / 500.0f + y;
        double z = y - lab[2] / 200.0f;
        double r, g, b;
        
        x = 0.95047f * ((x * x * x > 0.008856f) ? x * x * x : (x - 16.0f / 116.0f) / 7.787f);
        y = 1.00000f * ((y * y * y > 0.008856f) ? y * y * y : (y - 16.0f / 116.0f) / 7.787f);
        z = 1.08883f * ((z * z * z > 0.008856f) ? z * z * z : (z - 16.0f / 116.0f) / 7.787f);
        
        r = x * 3.2406f + y * -1.5372f + z * -0.4986f;
        g = x * -0.96890f + y * 1.8758f + z * 0.0415f;
        b = x * 0.05570f + y * -0.2040f + z * 1.0570f;
        
        r = (r > 0.0031308f) ? (1.055f * Math.pow(r, 1.0f / 2.4f) - 0.055f) : 12.92f * r;
        g = (g > 0.0031308f) ? (1.055f * Math.pow(g, 1.0f / 2.4f) - 0.055f) : 12.92f * g;
        b = (b > 0.0031308f) ? (1.055f * Math.pow(b, 1.0f / 2.4f) - 0.055f) : 12.92f * b;
        
        float[] rgb = new float[3];
        rgb[0] = constrain((float)r, 0, 1);
        rgb[1] = constrain((float)g, 0, 1);
        rgb[2] = constrain((float)b, 0, 1);
        return rgb;
    }


    float[] rgb01ToLab(float[] rgb) {
        double r = rgb[0];
        double g = rgb[1];
        double b = rgb[2];
        double x, y, z;

        r = (r > 0.04045f) ? Math.pow((r + 0.055f) / 1.055f, 2.4f) : r / 12.92f;
        g = (g > 0.04045f) ? Math.pow((g + 0.055f) / 1.055f, 2.4f) : g / 12.92f;
        b = (b > 0.04045f) ? Math.pow((b + 0.055f) / 1.055f, 2.4f) : b / 12.92f;

        x = (r * 0.4124f + g * 0.3576f + b * 0.1805f) / 0.95047f;
        y = (r * 0.2126f + g * 0.7152f + b * 0.0722f) / 1.00000f;
        z = (r * 0.0193f + g * 0.1192f + b * 0.9505f) / 1.08883f;

        x = (x > 0.008856f) ? Math.pow(x, 1.0f / 3.0f) : (7.787f * x) + 16.0f / 116.0f;
        y = (y > 0.008856f) ? Math.pow(y, 1.0f / 3.0f) : (7.787f * y) + 16.0f / 116.0f;
        z = (z > 0.008856f) ? Math.pow(z, 1.0f / 3.0f) : (7.787f * z) + 16.0f / 116.0f;

        float[] lab = new float[3];
        lab[0] = (float)(116.0f * y) - 16.0f;
        lab[1] = (float)(500.0f * (x - y));
        lab[2] = (float)(200.0f * (y - z));

        return lab;
    }
}
