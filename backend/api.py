from flask import Flask, jsonify, request
from flask_cors import CORS
import random

app = Flask(__name__)
CORS(app)

# Variables globales pour stocker l'état
class State:
    def __init__(self):
        self.reset()
        self.temp = round(random.uniform(10, 30), 1)
        self.luminosity = round(random.uniform(0, 1000), 1)
    
    def reset(self):
        # État des LEDs (-1: auto, 0: off, 1: on)
        self.led_red_state = 0
        self.led_green_state = 0
        # Seuils
        self.light_threshold = 10  # 10%
        self.temp_threshold = 25   # 25°C
        return self

    def update_temp(self):
        # Simule une variation de température
        self.temp += self.temp * random.uniform(-0.10, 0.10) # +/- 10%
        return self.temp

    def update_luminosity(self):
        # Simule une variation de luminosité
        self.luminosity += self.luminosity * random.uniform(-0.10, 0.10)
        return self.luminosity

state = State()


@app.route('/sensors', methods=['GET'])
def get_sensors():
    return jsonify({
        "temperature (C)": state.temp,
        "luminosite (Lux)": state.luminosity
    })

@app.route('/light', methods=['GET'])
def get_light():
    luminosity = state.luminosity
    # Conversion arbitraire en pourcentage (0-1000 Lux -> 0-100%)
    percentage = min(100, round((luminosity / 1000) * 100))
    return jsonify({
        "luminosite (Lux)": luminosity,
        "luminosite (%)": percentage
    })

@app.route('/temp', methods=['GET'])
def get_temperature():
    temperature = state.temp
    return jsonify({
        "temperature (C)": temperature
    })

@app.route('/led-red', methods=['GET'])
def set_led_red():
    print("demande de changement d'état de la led rouge")
    print("statue de la led rouge : ", state.led_red_state)
    state_param = request.args.get('state')
    if state_param is None:
        return "Paramètre state manquant", 400
    
    try:
        new_state = int(state_param)
        if new_state not in [-1, 0, 1]:
            return "Valeur state invalide", 400
        
        state.led_red_state = new_state
        print("nouveau state de la led rouge : ", state.led_red_state)
        if new_state == 1:
            return "Rouge LED allumée"
        else:
            return "Rouge LED éteinte"
    except ValueError:
        return "Paramètre state invalide", 400

@app.route('/led-green', methods=['GET'])
def set_led_green():
    print("demande de changement d'état de la led verte")
    print("statue de la led verte : ", state.led_green_state)
    state_param = request.args.get('state')
    if state_param is None:
        return "Paramètre state manquant", 400
    
    try:
        new_state = int(state_param)
        if new_state not in [-1, 0, 1]:
            return "Valeur state invalide", 400
        
        state.led_green_state = new_state
        print("nouveau state de la led verte : ", state.led_green_state)
        if new_state == 1:
            return "Verte LED allumée"
        else:
            return "Verte LED éteinte"
    except ValueError:
        return "Paramètre state invalide", 400

@app.route('/set-seuil', methods=['GET'])
def set_threshold():
    light = request.args.get('light')
    temp = request.args.get('temp')
    
    if light is None and temp is None:
        return "Au moins un paramètre (light ou temp) est requis", 400
    
    if light is not None:
        try:
            light_value = float(light)
            if not 0 <= light_value <= 100:
                return "Seuil de luminosité doit être entre 0 et 100%", 400
            state.light_threshold = light_value
        except ValueError:
            return "Valeur de luminosité invalide", 400
    
    if temp is not None:
        try:
            temp_value = float(temp)
            if not -40 <= temp_value <= 125:
                return "Seuil de température doit être entre -40 et 125°C", 400
            state.temp_threshold = temp_value
        except ValueError:
            return "Valeur de température invalide", 400
    
    return jsonify({    
        "tempThreshold": state.temp_threshold,
        "lightThreshold": state.light_threshold,
    })

@app.route('/reset', methods=['GET'])
def reset():
    state.reset()
    return "Paramètres réinitialisés", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)