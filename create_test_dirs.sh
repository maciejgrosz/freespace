rm -r test/
mkdir test
cd test
mkdir test_recursive
touch test.txt
touch test1.txt
bzip2 -z test1.txt
touch test2.txt
touch fc-oldziptest.txt
gzip fc-oldziptest.txt
touch -d "$(date -R -r fc-oldziptest.txt.gz) - 200 hours" fc-oldziptest.txt.gz
touch gzip_test.txt
gzip gzip_test.txt
touch test_recursive/test3.txt
mkdir test_recursive/test_recursive2
touch test_recursive/test_recursive2/test4.txt