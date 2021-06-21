#include <poppler-qt5.h>
#include <QtCore/QFile>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  if (argc < 2)
    return EXIT_FAILURE;

  Poppler::Document* doc = Poppler::Document::load(QFile::decodeName(argv[1]));
  Q_ASSERT(doc);
  Q_ASSERT(!doc->isLocked());

  int n_pages = doc->numPages();
  Q_ASSERT(n_pages > 0);

  delete doc;
  return EXIT_SUCCESS;
}
