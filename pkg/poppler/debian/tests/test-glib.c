#include <poppler.h>
#include <stdlib.h>

#ifdef TEST_GIO
#include <gio/gio.h>
#endif

int main(int argc, char *argv[])
{
  PopplerDocument* doc;
  int n_pages;
#ifdef TEST_GIO
  GError *error = NULL;
  GFile *file;
  GFileInfo *info;
  GInputStream *istream;
#endif

  if (argc < 2)
    return EXIT_FAILURE;

#if !defined(GLIB_VERSION_2_36)
  g_type_init();
#endif
  doc = poppler_document_new_from_file(argv[1], NULL, NULL);
  g_assert(doc != NULL);

  n_pages = poppler_document_get_n_pages(doc);
  g_assert_cmpint(n_pages, > , 0);

  g_object_unref(doc);

#ifdef TEST_GIO
  /* https://bugs.debian.org/896596 */

  file = g_file_new_for_uri(argv[1]);
  g_assert_nonnull(file);
  info = g_file_query_info(file, G_FILE_ATTRIBUTE_STANDARD_SIZE, G_FILE_QUERY_INFO_NONE, NULL, &error);
  g_assert_no_error(error);
  g_assert_nonnull(info);
  g_assert_cmpint(g_file_info_get_size(info), > , 0);

  istream = G_INPUT_STREAM(g_file_read(file, NULL, &error));
  g_assert_no_error(error);
  g_assert_nonnull(istream);
  doc = poppler_document_new_from_stream(istream, -1, NULL, NULL, &error);
  g_assert_no_error(error);
  g_assert_nonnull(doc);
  g_assert_cmpint(poppler_document_get_n_pages(doc), == , n_pages);
  g_object_unref(doc);
  g_object_unref(istream);

  istream = G_INPUT_STREAM(g_file_read(file, NULL, &error));
  g_assert_no_error(error);
  g_assert_nonnull(istream);
  doc = poppler_document_new_from_stream(istream, g_file_info_get_size(info), NULL, NULL, &error);
  g_assert_no_error(error);
  g_assert_nonnull(doc);
  g_assert_cmpint(poppler_document_get_n_pages(doc), == , n_pages);
  g_object_unref(doc);
  g_object_unref(istream);

  g_object_unref(info);
  g_object_unref(file);
#endif

  return EXIT_SUCCESS;
}
