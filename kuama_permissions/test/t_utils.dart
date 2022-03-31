void after(void Function() fn) => Future.delayed(const Duration(milliseconds: 1), fn);
