# TeaLayer implementation compatible with TensorFlow 2.16+ / Keras 3

import tensorflow as tf
import numpy as np

from tensorflow.keras import layers, activations, initializers


# --------------------------------------------------
# Stable sigmoid (avoid overflow)
# --------------------------------------------------

def sigmoid_custom(x, factor=1.0):
    return tf.nn.sigmoid(factor * x)


# --------------------------------------------------
# Custom round with straight-through gradient
# --------------------------------------------------

@tf.custom_gradient
def custom_round(x):

    y = tf.round(x)

    def grad(dy, variables=None):

        grad_x = dy

        if variables is not None:
            return grad_x, [None for _ in variables]

        return grad_x

    return y, grad


# --------------------------------------------------
# Connection clip (optional)
# --------------------------------------------------

@tf.custom_gradient
def custom_clip(x):

    y = tf.where(x > 0.5, tf.ones_like(x), tf.zeros_like(x))

    def grad(dy, variables=None):

        grad_x = dy

        if variables is not None:
            return grad_x, [None for _ in variables]

        return grad_x

    return y, grad


# --------------------------------------------------
# IBM Tea weight initializer
# --------------------------------------------------

def tea_weight_initializer(shape, dtype=tf.float32):

    num_axons = shape[0]
    num_neurons = shape[1]

    ret_array = np.zeros((num_axons, num_neurons), dtype=np.float32)

    for axon in range(num_axons):

        if axon % 2 == 0:
            ret_array[axon, :] = 1
        else:
            ret_array[axon, :] = -1

    return tf.convert_to_tensor(ret_array, dtype=dtype)


# --------------------------------------------------
# Tea Layer
# --------------------------------------------------

class Tea(layers.Layer):

    def __init__(
        self,
        units,
        threshold=0,
        activation="sigmoid_custom",
        activation_factor=1.0,
        use_bias=True,
        weight_initializer=None,
        bias_initializer="ones",
        connection_initializer=None,
        connection_regularizer=None,
        connection_constraint=None,
        clip_connections=True,
        round_bias=True,
        constrain_after_train=True,
        **kwargs
    ):

        super(Tea, self).__init__(**kwargs)

        self.units = units
        self.threshold = threshold
        self.use_bias = use_bias
        self.clip_connections = clip_connections
        self.round_bias = round_bias
        self.constrain_after_train = constrain_after_train

        # activation
        if activation == "sigmoid_custom":
            self.activation = lambda x: sigmoid_custom(x, factor=activation_factor)
        else:
            self.activation = activations.get(activation)

        # initializers
        if connection_initializer is None:
            self.connection_initializer = initializers.TruncatedNormal(
                mean=0.41, stddev=0.075
            )
        else:
            self.connection_initializer = connection_initializer

        if weight_initializer is None:
            self.weight_initializer = tea_weight_initializer
        else:
            self.weight_initializer = weight_initializer

        self.bias_initializer = bias_initializer
        self.connection_regularizer = connection_regularizer
        self.connection_constraint = connection_constraint


    # --------------------------------------------------

    def build(self, input_shape):

        input_dim = input_shape[-1]

        shape = (input_dim, self.units)

        self.static_weights = self.add_weight(
            name="weights",
            shape=shape,
            initializer=self.weight_initializer,
            trainable=False,
        )

        self.connections = self.add_weight(
            name="connections",
            shape=shape,
            initializer=self.connection_initializer,
            regularizer=self.connection_regularizer,
            constraint=self.connection_constraint,
            trainable=True,
        )

        if self.use_bias:

            self.biases = self.add_weight(
                name="bias",
                shape=(self.units,),
                initializer=self.bias_initializer,
                trainable=True,
            )

        super().build(input_shape)


    # --------------------------------------------------

    def call(self, inputs, training=False):

        # round connections (straight-through gradient)
        connections = custom_round(self.connections)

        # clip connections to [0,1]
        if self.clip_connections:
            connections = tf.clip_by_value(connections, 0.0, 1.0)

        # multiply with fixed weights
        weighted_connections = connections * self.static_weights

        # dot product
        potential = tf.matmul(inputs, weighted_connections)

        # bias
        if self.use_bias:

            if self.round_bias:
                biases = custom_round(self.biases)
            else:
                biases = self.biases

            potential = tf.nn.bias_add(potential, biases)

        # training vs inference
        if training:
            output = self.activation(potential)
        else:
            output = tf.cast(
                tf.greater_equal(potential, self.threshold),
                tf.float32,
            )

        return output


    # --------------------------------------------------

    def compute_output_shape(self, input_shape):

        return (input_shape[0], self.units)