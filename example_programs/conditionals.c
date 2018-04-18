
int main(int argc, char** argv)
{
  int foo = 1;
  if (foo) foo = foo + 1;
  else
  {
    foo = foo + 2;
  }
  if(1)
  {
    foo = 3;
  }
  else if (foo = 3) foo = 4;
  else foo = 5;
  return foo;
}
