if config["draw_phylotrees"]:
    rule iqtree_dna_tree_visualization:
        input:
            iqtree_dir_path / "fna" / f"{fasta_dna_filename}.treefile"
        output:
            iqtree_dir_path / "fna" / f"{fasta_dna_filename}.length_and_support_tree.svg",
            iqtree_dir_path / "fna" / f"{fasta_dna_filename}.only_support_tree.svg",
            iqtree_dir_path / "fna" / f"{fasta_dna_filename}.only_tree.svg"
        params:
            prefix=iqtree_dir_path / "fna" / f"{fasta_dna_filename}",
            options=config["iqtree_tree_visualization_params"]
        log:
            std=log_dir_path / "iqtree_dna_tree_visualization.log",
            cluster_log=cluster_log_dir_path / "iqtree_dna_tree_visualization.cluster.log",
            cluster_err=cluster_log_dir_path / "iqtree_dna_tree_visualization.cluster.err"
        benchmark:
            benchmark_dir_path / "iqtree_dna_tree_visualization.benchmark.txt"
        conda:
            "../../%s" % config["ete3_conda_config"]
        resources:
            cpus=config["visualization_threads"],
            time=config["visualization_time"],
            mem_mb=config["visualization_mem_mb"]
        threads:
            config["visualization_threads"]
        shell:
            "workflow/scripts/draw_phylotrees.py -i {input} -o {params.prefix} {params.options} 1> {log.std} 2>&1"


if config["draw_phylotrees"]:
    rule iqtree_protein_tree_visualization:
        input:
            iqtree_dir_path / "faa" / f"{fasta_protein_filename}.treefile"
        output:
            iqtree_dir_path / "faa" / f"{fasta_protein_filename}.length_and_support_tree.svg",
            iqtree_dir_path / "faa" / f"{fasta_protein_filename}.only_support_tree.svg",
            iqtree_dir_path / "faa" / f"{fasta_protein_filename}.only_tree.svg"
        params:
            prefix=iqtree_dir_path / "faa" / f"{fasta_protein_filename}",
            options=config["iqtree_tree_visualization_params"]
        log:
            std=log_dir_path / "iqtree_protein_tree_visualization.log",
            cluster_log=cluster_log_dir_path / "iqtree_protein_tree_visualization.cluster.log",
            cluster_err=cluster_log_dir_path / "iqtree_protein_tree_visualization.cluster.err"
        benchmark:
            benchmark_dir_path / "iqtree_protein_tree_visualization.benchmark.txt"
        conda:
            "../../%s" % config["ete3_conda_config"]
        resources:
            cpus=config["visualization_threads"],
            time=config["visualization_time"],
            mem_mb=config["visualization_mem_mb"]
        threads:
            config["visualization_threads"]
        shell:
            "workflow/scripts/draw_phylotrees.py -i {input} -o {params.prefix} {params.options} 1> {log.std} 2>&1"


if config["draw_phylotrees"]:
    rule astral_tree_visualization:
        input:
            astral_dir_path / astral_tree
        output:
            astral_dir_path / f"{astral_tree}.png",
            astral_dir_path / f"{astral_tree}.svg",
        params:
            prefix=astral_dir_path / astral_tree,
        log:
            std=log_dir_path / "astral_tree_visualization.log",
            cluster_log=cluster_log_dir_path / "astral_tree_visualization.cluster.log",
            cluster_err=cluster_log_dir_path / "astral_tree_visualization.cluster.err"
        benchmark:
            benchmark_dir_path / "astral_tree_visualization.benchmark.txt"
        conda:
            "../../%s" % config["ete3_conda_config"]
        resources:
            cpus=config["visualization_threads"],
            time=config["visualization_time"],
            mem_mb=config["visualization_mem_mb"]
        threads:
            config["visualization_threads"]
        shell:
            "workflow/scripts/draw_phylotrees_from_astral.py -i {input} -o {params.prefix} > {log.std} 2>&1"
