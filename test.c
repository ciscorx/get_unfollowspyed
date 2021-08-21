#include <stdio.h>

#include <openssl/evp.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <argp.h>


// T at 136,65,7,12
// ./fmip b4855917f957c0912eaa1625b54b7103 7 12 fullscreen.ppm
void bytes2md5(const char *data, int len, char *md5buf) {
  // Based on https://www.openssl.org/docs/manmaster/man3/EVP_DigestUpdate.html
  EVP_MD_CTX *mdctx = EVP_MD_CTX_new();
  const EVP_MD *md = EVP_md5();
  unsigned char md_value[EVP_MAX_MD_SIZE];
  unsigned int md_len, i;
  EVP_DigestInit_ex(mdctx, md, NULL);
  EVP_DigestUpdate(mdctx, data, len);
  EVP_DigestFinal_ex(mdctx, md_value, &md_len);
  EVP_MD_CTX_free(mdctx);
  for (i = 0; i < md_len; i++) {
    snprintf(&(md5buf[i * 2]), 16 * 2, "%02x", md_value[i]);
  }
}

int main2(int argc, char* argv[]) {
  const char *hello = "hello";
  char md5[33]; // 32 characters + null terminator
  bytes2md5(argv[1], strlen(argv[1]), md5);
  printf("%s\n", md5);
}

int count_the_commas_in_a_string_and_put_their_positions_in_a_list(char* string, int* list) {
    int cntr,pos, pos_end,i;
    cntr=0;
    pos=0;
    pos_end = strlen(string);
    for(i=0;i<pos_end;i++)
	if (string[i]==',') {
	    list[i]=i;
	    cntr++;
	}
    return cntr;
}

void strcpy_slice_from_pos1_to_pos2(char* target,char* string,int pos1,int pos2) {
    int i, target_pos;
    target_pos = 0;
    for (i=pos1;i<pos2;i++) {
	if ( string[i] != ' ' ) {
	    target[target_pos] = string[i];
	    target_pos++;
	}
    }
    return;
}
					
void get_item_from_comma_separated_string( int idx, char* string,int* comma_position, int commas, char* target) {
    int pos_begin, pos_end;
    if (commas == 0) {   /* only zero or one element */
	strcpy(target,string);
	return;
    }
    if (idx == commas) {   /* last element */
	strcpy(target,*(string + comma_position[idx]));
	return;
    }

    if (idx == 0) {       /* 1st element */
	strcpy_slice_from_pos1_to_pos2(&target,string,0,comma_position[0]);
	return;
    }

    /* element somewhere in between */
    strcpy_slice_from_pos1_to_pos2(&target,string,comma_position[idx-1],comma_position[idx]);
    return;
}



int isPositiveNumber(char number[])
{
    int i;

    for (i=0; number[i] != NULL && i<12; i++)
    {
        if (!isdigit(number[i]))
            return 0;
    }
    return 1;
}

int doesFileExistForRead(char* fname) {
    if( access( fname, R_OK ) == 0 ) {
    // file exists
	return 1;
    } else {
	return 0;
    // file doesn't exist
    }
}


int main(int argc, char *argv[]) {
  const int dimx = 800, dimy = 800;
  
  printf("%d",argc);
}
