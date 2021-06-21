#include <poppler-document.h>
#include <assert.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  if (argc < 2)
    return EXIT_FAILURE;

  poppler::document* doc = poppler::document::load_from_file(argv[1]);
  assert(doc);
  assert(!doc->is_locked());

  int n_pages = doc->pages();
  assert(n_pages > 0);

  delete doc;
  return EXIT_SUCCESS;
}
