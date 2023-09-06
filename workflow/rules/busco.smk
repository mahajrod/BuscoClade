
rule busco5_download:
    output:
        lineage_dir=directory(busco_download_dir_path / config["busco_lineage"]),
    params:
        busco_lineage=config["busco_lineage"],
        busco_download_dir=busco_download_dir_path
    log:
        std=log_dir_path / "busco5_download.log",
        cluster_log=cluster_log_dir_path / "busco5_download.cluster.log",
        cluster_err=cluster_log_dir_path / "busco5_download.cluster.err"
    benchmark:
        output_dict["benchmark"] / "busco5_download.benchmark.txt"
    conda:
        "../../%s" % config["conda_config"]
    resources:
        cpus=config["busco5_download_threads"],
        time=config["busco5_download_time"],
        mem=config["busco5_download_mem_mb"],
    threads:
        config["busco5_download_threads"],
    shell:
         " busco --download_path {params.busco_download_dir} --download {params.busco_lineage} > {log.std} 2>&1; "

if config['gene_prediction_tool'] == "metaeuk":
    rule busco_metaeuk:
        input:
            fasta=genome_dir_path / "{species}.fasta",
            busco_dataset_path=config["busco_dataset_path"] if config["busco_dataset_path"] else rules.busco5_download.output.lineage_dir
        output:
            busco_outdir=directory(busco_dir_path / "{species}"),
            single_copy_busco_sequences=directory(busco_dir_path / "{species}/busco_sequences/single_copy_busco_sequences"),
            summary=busco_dir_path / "{species}/short_summary_{species}.txt"
        params:
            mode=config["busco_mode"],
            busco_dataset_path=config["busco_dataset_path"],
            output_prefix="{species}"
        log:
            std=log_dir_path / "busco.{species}.log",
            cluster_log=cluster_log_dir_path / "busco.{species}.cluster.log",
            cluster_err=cluster_log_dir_path / "busco.{species}.cluster.err"
        benchmark:
            benchmark_dir_path / "busco.{species}.benchmark.txt"
        conda:
            "../../%s" % config["conda_config"]
        resources:
            cpus=config["busco_threads"],
            time=config["busco_time"],
            mem_mb=config["busco_mem_mb"],
        threads:
            config["busco_threads"]
        shell:
            "mkdir -p {output.busco_outdir}; cd {output.busco_outdir}; "
            "busco -m {params.mode} -i {input.fasta} -c {threads} "
            "-l {input.busco_dataset_path} -o {params.output_prefix} 1>../../../{log.std} 2>&1; "
            "mv {params.output_prefix}/* . 1>../../../{log.std} 2>&1; "
            "rm -r {params.output_prefix}/ 1>../../../{log.std} 2>&1; "
            "rm -r busco_sequences/ 1>../../../{log.std} 2>&1; " # empty directory
            "mv run*/* . 1>../../../{log.std} 2>&1; "
            "rm -r run* 1>../../../{log.std} 2>&1; "
            "mv full_table.tsv full_table_{params.output_prefix}.tsv 1>../../../{log.std} 2>&1; "
            "mv missing_busco_list.tsv missing_busco_list_{params.output_prefix}.tsv 1>../../../{log.std} 2>&1; "
            "mv short_summary.txt short_summary_{params.output_prefix}.txt 1>../../../{log.std} 2>&1; "

elif config['gene_prediction_tool'] == "augustus":
    rule busco_augustus:
        input:
            fasta=genome_dir_path / "{species}.fasta",
            busco_dataset_path=config["busco_dataset_path"] if config["busco_dataset_path"] else rules.busco5_download.output.lineage_dir
        output:
            busco_outdir=directory(busco_dir_path / "{species}"),
            single_copy_busco_sequences=directory(busco_dir_path / "{species}/single_copy_busco_sequences"),
            augustus_gff=directory(busco_dir_path / "{species}/augustus_output/gff"),
            summary=busco_dir_path / "{species}/short_summary_{species}.txt"
        params:
            mode=config["busco_mode"],
            species=config["augustus_species"],
            busco_dataset_path=config["busco_dataset_path"],
            output_prefix="{species}"
        log:
            std=log_dir_path / "busco.{species}.log",
            cluster_log=cluster_log_dir_path / "busco.{species}.cluster.log",
            cluster_err=cluster_log_dir_path / "busco.{species}.cluster.err"
        benchmark:
            benchmark_dir_path / "busco.{species}.benchmark.txt"
        conda:
            "../../%s" % config["conda_config"]
        resources:
            cpus=config["busco_threads"],
            time=config["busco_time"],
            mem_mb=config["busco_mem_mb"],
        threads:
            config["busco_threads"]
        shell:
            "mkdir -p {output.busco_outdir}; cd {output.busco_outdir}; "
            "busco --augustus --augustus_species {params.species} -m {params.mode} "
            "-i {input.fasta} -c {threads} -l {input.busco_dataset_path} -o {params.output_prefix} 1>../../../{log.std} 2>&1; "
            "mv {params.output_prefix}/* ./ ; rm -r {params.output_prefix}/ ; "
            "rm -r augustus_output/ ; " # empty directory
            "mv run*/* . ; rm -r run* ; "
            "mv full_table.tsv full_table_{params.output_prefix}.tsv ; "
            "mv missing_busco_list.tsv missing_busco_list_{params.output_prefix}.tsv ; "
            "mv short_summary.txt short_summary_{params.output_prefix}.txt ; "


