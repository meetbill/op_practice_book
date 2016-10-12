#########################################################################
# File Name: run_web.sh
# Author: Bill
# mail: 
# Created Time: 2016-10-12 13:17:27
#########################################################################
#!/bin/bash
# 通过markdown文件生成html文件，并建立web service访问html

HTML_DIR='html_tmp'

PORT=8000
if [ $# -ne 0 ]
then
    if [[ $1 =~ ^[0-9]+$ ]]
    then
        PORT=$1
        echo ${PORT}
    fi
fi

CHECK=`rpm -qa | grep 'pandoc'| wc -l`
if [[ w${CHECK} == w0 ]]
then
    echo "this system not have pandoc!"
    echo "you must run:yum -y install pandoc"
    exit
fi
[[ -d "${HTML_DIR}" ]] && rm -rf ${HTML_DIR}
mkdir -p ${HTML_DIR}
cp -rf ./images ${HTML_DIR}

find . -name "*.md" | while read md_file
do
    #echo ${md_file}
    PATH_FILE=`dirname ${md_file}`
    if [ ! -d "${HTML_DIR}/${PATH_FILE}" ]
    then
        mkdir -p ${HTML_DIR}/${PATH_FILE}
    fi
    file_name=$(echo ${md_file} | sed "s/\.md$//")
    pandoc -f markdown -t html --html5 --atx-headers ${md_file} > ${HTML_DIR}/${file_name}.html
    sed -i "s/.md/.html/g" ${HTML_DIR}/${file_name}.html
done

cd ${HTML_DIR}
echo "http://localhost:${PORT}"
python -m SimpleHTTPServer ${PORT}
