import pandas as pd
import tensorflow as tf
import keras_tuner as kt

# Funcao para gerar dataset a partir do conjunto de dados
def dataframe_2_dataset(dataframe, batch_size):
  labels = dataframe.pop(0)
  data_array = dataframe.to_numpy()
  matrices = [data_array[i].reshape((10, 10, 1)) for i in range(len(dataframe))]
  dataset = tf.data.Dataset.from_tensor_slices((matrices, labels))
  dataset = dataset.batch(batch_size)
  return dataset

def criar_modelo_cnn(hp):
  # Camada Entrada
  input = tf.keras.Input(shape=(10, 10, 1))

  # Camada Convolucional 1
  hp_conv1_filters = hp.Int('hp_conv1_filters', min_value=4, max_value=64, step=4)
  conv1 = tf.keras.layers.Conv2D(hp_conv1_filters, (3, 3), activation='relu')(input)

  # Camada Convolucional 2
  hp_conv2_filters = hp.Int('hp_conv2_filters', min_value=4, max_value=128, step=4)
  conv2 = tf.keras.layers.Conv2D(hp_conv2_filters, (3, 3), activation='relu')(conv1)

  # Camada Convolucional 3
  hp_conv3_filters = hp.Int('hp_conv3_filters', min_value=4, max_value=128, step=4)
  conv3 = tf.keras.layers.Conv2D(hp_conv3_filters, (3, 3), activation='relu')(conv2)

  # Camada MaxPooling
  max_pool = tf.keras.layers.MaxPooling2D((2, 2))(conv3)

  # Camada Flatten
  flatten = tf.keras.layers.Flatten()(max_pool)

  # Camada Densa
  hp_dense_units = hp.Int('hp_dense_units', min_value=64, max_value=256, step=8)
  dense = tf.keras.layers.Dense(hp_dense_units, activation='relu')(flatten)

  # Camada Saída
  output = tf.keras.layers.Dense(1, activation='sigmoid')(dense)

  # Combina as camadas em um modelo sequencial
  model = tf.keras.Model(inputs=input, outputs=output)

  # Define a razao de aprendizado
  hp_learning_rate = hp.Choice('learning_rate', values=[1e-1, 1e-2, 1e-3, 1e-4, 1e-5])

  # Compila o modelo, define o otimizador, a funcao de perda e as metricas
  model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=hp_learning_rate),
                 loss=tf.keras.losses.BinaryCrossentropy(),
                 metrics=[tf.keras.metrics.BinaryAccuracy()])

  return model

# Carrega e aleatoriza o conjunto de treinamento
dataframe_treinamento= pd.read_csv('/pole/datasets/treinamento.csv', header=None).sample(frac=1, random_state=32)
print('Quantidade de dados de treinamento: ', len(dataframe_treinamento))

# Separa 10% dos dados de treinamento para a busca
dataframe_busca_treinamento = dataframe_treinamento.copy().sample(frac=0.10, random_state=32)
print('Quantidade de dados de treinamento para busca: ', len(dataframe_busca_treinamento))

# Separa 10% dos dados de treinamento da busca (separados acima) para a validacao
dataframe_busca_validacao = dataframe_busca_treinamento.copy().sample(frac=0.10, random_state=32)
print('Quantidade de dados de validacao para busca: ', len(dataframe_busca_validacao))

# Cria o dataset de treinamento e validacao
dataset_busca_treinamento = dataframe_2_dataset(dataframe_busca_treinamento, 64)
dataset_busca_validacao = dataframe_2_dataset(dataframe_busca_validacao, 64)

# Cria o KerasTurner com os parametros indicados
tuner = kt.Hyperband(hypermodel=criar_modelo_cnn,
                     objective='val_binary_accuracy',
                     max_epochs=1000,
                     directory='keras_test_45',
                     project_name='pole_position')

# Define a funcao de parada monitorando o valor de perda da validacao
stop_early = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=50)

# Realiza a busca dos hiper-parametros
tuner.search(dataset_busca_treinamento, validation_data=dataset_busca_validacao, epochs=1000, callbacks=[stop_early])

# Obtem os melhores parametros encontrados
best_hps=tuner.get_best_hyperparameters(num_trials=1)[0]

print('hp_conv1_filters: ', best_hps.get('hp_conv1_filters'))
print('hp_conv2_filters: ', best_hps.get('hp_conv2_filters'))
print('hp_conv3_filters: ', best_hps.get('hp_conv3_filters'))
print('hp_dense_units: ', best_hps.get('hp_dense_units'))
print('learning_rate: ', best_hps.get('learning_rate'))
print('tuner/epochs: ', best_hps.get('tuner/epochs'))