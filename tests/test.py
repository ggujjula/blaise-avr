import unittest
from parameterized import parameterized
import os
import subprocess

numPass = 0
numFail = 0
numXFail = 0
numXPass = 0
numSkip = 0

def printSummary():
  print('Summary')
  print('Passed:', numPass)
  print('Failed:', numFail)
  print('XFailed:', numXFail)
  print('XPassed:', numXPass)
  print('Skipped:', numSkip)

class LexerTestCase(unittest.TestCase):
  @parameterized.expand(
    ([name] for name in os.listdir('../tests/lexer') if name.endswith('.pas')),
    skip_on_empty = True
  )
  def test_lexer(self, name):
    test_input_path = '../tests/lexer/' + name
    test_output_path = './testresults/lexer/' + name + '.test'
    subprocess.run(['mkdir', '-p', './testresults/lexer']) 
    subprocess.run(['touch', test_output_path]) 
    test_input = open(test_input_path, mode = 'rb')
    test_output = open(test_output_path, mode = 'wb')
    subprocess.run(['./lexertester'], stdin = test_input, stdout = test_output) 
    test_input.close()
    test_output.close()
    test_diff_path = './testresults/lexer/' + name + '.diff'
    subprocess.run(['touch', test_diff_path]) 
    test_diff = open(test_diff_path, mode = 'wb')
    result = True
    try:
      subprocess.run(['diff', test_input_path + '.test', test_output_path], check = True, stdout = test_diff) 
    except subprocess.CalledProcessError:
      result = False
    test_diff.close()
    if not result:
      test_diff = open(test_diff_path, mode = 'r')
      diff_excerpt = ''
      for i in range(5):
        line = test_diff.readline()
        if line == '':
          break
        diff_excerpt += line
      test_diff.close()
      raise AssertionError(name + ': diff in outputs:\n' + diff_excerpt + '\nSee ' + test_diff_path + ' for more.')
    else:
      subprocess.run(['rm', test_output_path, test_diff_path]) 

class ParserTestCase(unittest.TestCase):
  @parameterized.expand(
    ([name] for name in os.listdir('../tests/parser') if name.endswith('.pas')),
    skip_on_empty = True
  )
  def test_parser(self, name):
    return

class CodegenTestCase(unittest.TestCase):
  @parameterized.expand(
    ([name] for name in os.listdir('../tests/codegen') if name.endswith('.pas')),
    skip_on_empty = True
  )
  def test_codegen(self, name):
    return

if __name__ == '__main__':
  if not os.getcwd().endswith('/blaise-avr/build'):
    print('Run in build folder')
  else:
    unittest.main()
    #printSummary()
