from setuptools import setup

def readme():
    with open('../README.md') as f:
        return f.read()

setup(name='tealayer4',
      version='4.0',
      description='TensorFlow 2.0 Layers for running TeaLearning Networks',
      classifiers=[
          'Programming Language :: Python :: 3.6.8'
          ],
      url='FIXME',
      author='Spencer Valancius, Ruben Purdy',
      author_email='svalancius12@email.arizona.edu, rubenpurdy@email.arizona.edu',
      license='MIT',
      packages=['tealayer4'],
      install_requires=[
          'tensorflow',
          'numpy',
          'Pillow'
          ],
      zip_safe=False)
