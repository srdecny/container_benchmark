import matplotlib.pyplot as plt
import pandas as pd

def parse_docker_postgres(path):
	docker_postgres = pd.read_csv(path, names=["start", "end"])
	docker_postgres["seconds"] = (docker_postgres["end"] - docker_postgres["start"]) / 1_000_000_000
	return docker_postgres

def parse_docker_alpine(path):
	docker_alpine = pd.read_csv(path, names=["start", "end"])
	# For some reason the alpine timestamp is sometimes missing a digit.
	def pad(val):
		diff = 19 - len(str(val))
		if diff != 0:
			val = val * 10 ** diff
		return val
	docker_alpine["end"] = docker_alpine["end"].apply(pad)
	docker_alpine["seconds"] = (docker_alpine["end"] - docker_alpine["start"]) / 1_000_000_000
	return docker_alpine

def parse_network(path):
	def parse_duration(timestamp):
		minutes, seconds = timestamp[:-1].split("m")
		return int(minutes) * 60 + float(seconds.replace(",", "."))
	network = pd.read_csv(path, names=["duration"], delimiter="#")
	network["seconds"] = network["duration"].apply(parse_duration)
	return network

graphs = [
	["startup_postgres", [
		[parse_docker_postgres("./logs/docker_init_postgres_runc.csv"), "docker (runc)"],
		[parse_docker_postgres("./logs/docker_init_postgres_crun.csv"), "docker (crun)"],
		[parse_docker_postgres("./logs/podman_init_postgres_crun.csv"), "podman (crun)"],
	]],
	["startup_alpine", [
		[parse_docker_alpine("./logs/docker_init_alpine_runc.csv"), "docker (runc)"],
		[parse_docker_alpine("./logs/docker_init_alpine_crun.csv"), "docker (crun)"],
		[parse_docker_alpine("./logs/podman_init_alpine_crun.csv"), "podman (crun)"],
	]],
	["network_throughput", [
		[parse_network("./logs/podman_crun_nc.csv"), "podman (crun)"],
		[parse_network("./logs/docker_runc_nc.csv"), "docker (runc)"],
		[parse_network("./logs/docker_crun_nc.csv"), "docker (crun)"],
	]]
]

for graph_name, data in graphs:
	fig, ax = plt.subplots()
	for line, label in data:
		total = round(line["seconds"].sum(), 2)
		ax = line["seconds"].plot(label=f"{label} total: {total} s")

	ax.set_xlabel("Iteration")
	ax.set_ylabel("Time (s)")
	ax.set_title(graph_name)
	ax.legend()

	plt.savefig(f"./graphs/{graph_name}.png")