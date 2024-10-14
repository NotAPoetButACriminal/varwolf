## Installation

1. Clone the reposirotory:

```git clone https://github.com/NotAPoetButACriminal/varwolf.git```

2. Navigate to the cloned directory and build the docker image:

```docker build -t varwolf:latest .```

3. Run the database install script which will download the hg38 reference genome and all the necessary annotation files:

```docker run --rm -itv /path/to/varwolf/:/root/varwolf/ varwolf:latest database_install```

## Usage

### Annotating variants
**varannosaur** is the script for annotating variants files using Ensembl VEP. Place a vcf file anywhere in the varwolf directory (such as the input/ directory), and run the following command:

```docker run --rm -v /path/to/varwolf/:/root/varwolf varwolf:latest varannosaur input/variants.vcf(.gz)```

The result is a table of annotated variants in tab-delimited format that is stored in the output/ directory and will have the name "*_annotated.tsv"
