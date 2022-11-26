localrules: species_ids, common_ids, merged_sequences

rule species_ids: # get files with IDs for each species
    input:
        busco_dir_path / "{species}/busco_sequences/single_copy_busco_sequences"
    output:
        species_ids_dir_path / "{species}.ids"
    log:
        std=log_dir_path / "species_ids.{species}.log",
        cluster_log=cluster_log_dir_path / "species_ids.{species}.cluster.log",
        cluster_err=cluster_log_dir_path / "species_ids.{species}.cluster.err"
    benchmark:
        benchmark_dir_path / "species_ids.{species}.benchmark.txt"
    resources:
        cpus=config["species_ids_threads"],
        time=config["species_ids_time"],
        mem_mb=config["species_ids_mem_mb"]
    shell:
        "ls {input} | grep -P '.fna$' | sed 's/.fna//' > {output} 2> {log.std}"


rule common_ids: # get common IDs for all species and split them into files
    input:
        expand(species_ids_dir_path / "{species}.ids", species=config["species_list"])
    output:
        common_ids_dir_path / "common_ids.ids"
    params:
        nfiles=len(config["species_list"])
    log:
        std=log_dir_path / "common_ids.log",
        cluster_log=cluster_log_dir_path / "common_ids.cluster.log",
        cluster_err=cluster_log_dir_path / "common_ids.cluster.err"
    benchmark:
        benchmark_dir_path / "common_ids.benchmark.txt"
    resources:
        cpus=config["common_ids_threads"],
        time=config["common_ids_time"],
        mem_mb=config["common_ids_mem_mb"]
    shell:
        "cat {input} | sort | uniq -c | awk '{{if($1=={params.nfiles}){{print $2}}}}' > {output} 2> {log.std}; "


checkpoint merged_sequences: # get merged sequences by common IDs
    input:
        rules.common_ids.output
    output:
        directory(merged_sequences_dir_path)
    params:
        single_copy_files=expand(busco_dir_path / "{species}/busco_sequences/single_copy_busco_sequences", species=config["species_list"])
    log:
        std=log_dir_path / "merged_sequences.log",
        cluster_log=cluster_log_dir_path / "merged_sequences.cluster.log",
        cluster_err=cluster_log_dir_path / "merged_sequences.cluster.err"
    benchmark:
        benchmark_dir_path / "merged_sequences.benchmark.txt"
    resources:
        cpus=config["merged_sequences_threads"],
        time=config["merged_sequences_time"],
        mem_mb=config["merged_sequences_mem_mb"]
    shell:
        "workflow/scripts/merge_common_ids.py --common_ids {input} "
        "--single_copy_files {params.single_copy_files} --outdir {output} 1> {log.std} 2>&1"