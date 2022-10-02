from setuptools import setup
from os import path

here = path.abspath(path.dirname(__file__))
with open(path.join(here, 'README.md')) as f:
    long_description = f.read()

setup(name='dgut-inet-auth',
      version='0.3',
      description='Log in to DGUT campus internet',
      long_description=long_description,
      long_description_content_type='text/markdown',
      author='Zhu Chuang',
      author_email='pypi@chuang.cz',
      packages=[],
      scripts=['dgut-inet-auth'],
      python_requires='>=3.7',
      install_requires=['requests', 'pycryptodome'])
