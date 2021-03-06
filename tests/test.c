#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>


int main(int argc, char *argv[]){
  int num_pass = 0;
  int num_fail = 0;
  int num_xpass = 0;
  int num_xfail = 0;
  int num_skip = 0;

  int num_paths = 3;
  char **paths = {
    "../tests/lexer",
    "../tests/parser",
    "../tests/codegen"
  };

  DIR *test_dir = NULL;

  for(int i = 0; i < num_paths; i++){
    char *path = paths[i];
    test_dir = opendir(path);
  if(test_dir == NULL){
    printf("Could not open test dir %s\n", path);
    return 1;
  }
  while(entry = readdir(test_dir)){
    struct stat entrystat;

    if(!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")){
      continue;
    }
    
    fstatat(dirfd(test_dir), entry->d_name, &entrystat, 0);
    if(S_ISDIR(entrystat.st_mode)){
      char * subdir_path = malloc(strlen(entry->d_name) + strlen(path) + 1);
      strcpy(subdir_path, path);
      strcat(subdir_path, "/");
      strcat(subdir_path, entry->d_name);
      //printf("%s\n", subdir_path);
      test_subdir = opendir(subdir_path);
      if(test_subdir == NULL){
        printf("Could not open test dir %s\n", subdir_path);
        return 1;
      }
      while(entry = readdir(test_subdir)){
        printf("%s\n", entry->d_name);
      }
    }
  }
}
