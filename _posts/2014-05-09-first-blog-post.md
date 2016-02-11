---
layout: post
title: first blog post
date: 2014-05-09
---
# 初めての投稿
とりあえず初めてなのでどんな感じに出来るのかのテストです

## シンタックスハイライトのチェック

{% highlight c linenos %}
#include<stdio.h>
#include<string.h>
 
int min(int a, int b) {
return a<b?a:b;
}
 
 
int levenshtein(char *str1,char *str2){
int str1len = strlen(str1);
int str2len = strlen(str2);
char buf1[str1len+1];
char buf2[str2len+1];
char buf3[str1len+1];
char buf4[str2len+1];
 
strcpy(buf1,str1);
strcpy(buf2,str2);
buf1[str1len-1]='\0';
buf2[str2len-1]='\0';
int i;
for(i=1;i<=str1len;i++){
buf3[i-1]=str1[i];
}
buf3[str1len] = '\0';
 
for(i=1;i<=str2len;i++){
buf4[i-1]=str2[i];
}
buf4[str2len] = '\0';
if(!strcmp(str1,str2)){
return 0;
}
 
if(!strcmp(str1,"")){
return str1len;
}
 
if(!strcmp(str2,"")){
return str2len;
}
 
return min(min(1+levenshtein(buf1,buf2),
min(1+levenshtein(buf1,str2),
1+levenshtein(str1,buf2))),
min(1+levenshtein(buf3,buf4),
min(1+levenshtein(buf3,str2),
1+levenshtein(str1,buf4))));
}
 
 
 
int main(void){
char str1[256] = {'\0'};
char str2[256] = {'\0'};
scanf("%s",str1);
scanf("%s",str2);
 
int n = levenshtein(str1,str2);
printf("%d\n",n);
return 0;
}

{% endhighlight %}

## Gistを貼り付けるチェック
{% gist kimiboku/a7b180ac380caad7e6ca levenshtein.c %}
