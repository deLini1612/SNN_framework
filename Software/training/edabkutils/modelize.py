import json
import math

def get_configs(layer_inputs):
  '''Get user configurations from Colab interaction'''

  first_layer = True
  for layer in layer_inputs:
    for i in range(3):
      if layer[i+1].value <= 0:
        raise ValueError(f"Negative hyperparameter: {layer[i+1].value}")

    axons = layer[1].value*layer[2].value
  
    if (not first_layer): # Not the first layer
      if (axons != neurons):
        raise ValueError(f"Total neurons in layer i have to equal total axons in layer i+1")
    else: # First layer
      first_layer = False
      if (len(layer_inputs) == 1): # There is just 1 layer
        if (layer[1].value == 1) & (layer[2].value == math.floor(math.sqrt(layer[2].value))*math.floor(math.sqrt(layer[2].value))):
          return [[layer[1].value, layer[2].value, layer[3].value] for layer in layer_inputs]
        else:
          raise ValueError(f"If there is just 1 layer, there is only 1 core and number of axons have to be square")
    neurons = layer[1].value*layer[3].value
  return [[layer[1].value, layer[2].value, layer[3].value] for layer in layer_inputs]

def get_core_arrange(model_configs):
  '''Calculate core physical arrangement in network'''
  num_layer = len(model_configs)
  network_arrange = []
  x_range = 0
  y_range = num_layer

  for layer_ind in range(num_layer):
    layer_arrange = []
    if (model_configs[layer_ind][0] > x_range):
      x_range = model_configs[layer_ind][0]
    for core_ind in range(model_configs[layer_ind][0]):
      layer_arrange.append([core_ind, layer_ind])
    network_arrange.append(layer_arrange)
  
  return [x_range, y_range, network_arrange]

def save_configure_json(file, model_configs):
  '''Save model configuration to .json file'''
  # Initialize an empty list to store the cores' information
  cores = []

  # Initialize variables to keep track of the coordinates and core IDs
  core_id = 1
  x_coordinate = 0  # Will increase as we move to the next layer
  y_coordinate = 0  # Will increase as we move to the next core

  # Iterate over the layers to generate core information
  for layer in model_configs:
      num_cores = layer[0]
      num_axon = layer[1]
      num_neuron = layer[2]
      
      # Generate core information for each layer
      for i in range(num_cores):
          # Create the core's dictionary
          core = {
              "id": core_id,
              "coordinates": [x_coordinate, y_coordinate],
              "num_neuron": num_neuron,
              "num_axon": num_axon
          }
          # Append to the cores list
          cores.append(core)
          
          # Update the core ID and y-coordinate for the next core
          core_id += 1
          y_coordinate += 1
      
      # After processing all cores in this layer, update the x-coordinate, reset y-coordinate for the next layer
      x_coordinate += 1
      y_coordinate = 0


  # Create the final structure
  core_arrange = get_core_arrange(model_configs)
  model_data = {"cores": cores, "core_arrange":core_arrange}

  # Write the data to a JSON file
  with open(file, "w") as json_file:
    json.dump(model_data, json_file, indent=4, separators=(',', ': '))
          
  print(f"Model configuration is saved into {file}.")


def auto_train_config(core_num, core_axon_num, fold_ratio = 0.25):
  '''Calculate configuration for training corresponding with network config'''
  if (core_num == 1):
    if (fold_ratio != 0):
      raise ValueError(f"If there is just 1 core in the first layer, fold_ratio have to be 0 (no fold)")
    pic_size = math.floor(math.sqrt(core_axon_num))
    return [pic_size, [[0,core_axon_num]]]

  fold = math.floor(core_axon_num*fold_ratio)
  pic_size = math.floor(math.sqrt(core_num*core_axon_num - (core_num-1)*fold))
  fold = (core_num*core_axon_num - pic_size*pic_size)//(core_num-1)
  slice_ind = []

  for i in range (core_num):
      slice_ind.append([core_axon_num*i - fold*i, core_axon_num*(i+1) - fold*i])
  
  return [pic_size, slice_ind]
 
 
def write_config_sim(file, num_neurons, num_axons, x_range, y_range, neuron_block_trace, core_trace):
    '''Function to write the config file to run the simulation'''
    data = {
        "num_neurons": num_neurons,
        "num_axons": num_axons,
        "num_cores_x": x_range,
        "num_cores_y": y_range,
        "num_weights": 4,
        "max_tick_offset": 16,
        "neuron_block_trace_verbosity": neuron_block_trace,
        "core_controller_trace_verbosity": core_trace,
        "scheduler_trace_verbosity": 0,
        "neuron_reset_type": 0
    }

    with open(file, "w") as f:
        json.dump(data, f, indent=4)
    print(f"Write C++ simulation config file to {file}")
