### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 2a08a1f7-4a60-49b3-abd0-fa243bdcae79
begin
	using Plots
	using DelimitedFiles
	using FastGaussQuadrature
	using SparseArrays
	using LoopVectorization
end

# ╔═╡ 7026f9c4-40a9-11ec-1568-3b997fceb607
begin
	const get_l = Dict(
		1=>(1,1),
		2=>(2,1),
		3=>(2,2),
		4=>(1,2),
	)
end

# ╔═╡ dd81b82b-13ac-4b10-8746-6c1901d24d7c
struct Params
	nx::Int32
	ny::Int32
end

# ╔═╡ c22e5519-6054-4eef-81b7-4907809b6e87
get_Δx(p::Params) =  π/(p.nx-1)

# ╔═╡ be5564c1-ed0d-4732-8215-e016c2cbc5aa
get_Δy(p::Params) =  π/(p.ny-1)

# ╔═╡ d760ffc2-de02-416e-b24a-065af382db42
x_range(p::Params) = 0:get_Δx(p):π

# ╔═╡ cb5a6eb8-f350-426b-b06d-8c3d6eac2447
y_range(p::Params) = 0:get_Δy(p):π

# ╔═╡ 389ce350-5c42-459b-9d27-ecf00cf69712
get_M(p::Params) = (p.nx-1)*(p.ny-1)

# ╔═╡ 8748750f-1863-4ddc-ad05-c65409e95d43
# i - numer węzła lokanlego od 1 do 4. (zielony)
# m - numer elementu 
# INDEKS GLOBALNY od 1 do M
function nr(i,m)
	if i == 1
		return i + (j-1) * nx
	if i == 2
		return (i+1) + (j-1)*nx
	end
	if i == 3
		return (i+1)+(j)*nx
	end
	if i == 4
		return i + j*nx
	end
	return 
	end
end

# ╔═╡ 9df918b6-e1b5-458d-98c3-4334918d2d5d
# INDEKS GLOBALNY od 1 do M
n(m, l) = nr(l, m)

# ╔═╡ 68b5857f-3699-4014-9f0d-f61dbca894f9
get_m(i,j, p::Params) = i + (j-1)*(p.nx-1)

# ╔═╡ 4aa5d20f-704f-4b0d-92a6-5dd87fa2634e
ϕ = [
	ξ-> 1/2 - 3/4*ξ+1/4*ξ^3 	ξ-> 1/2 + 3/4*ξ-1/4*ξ^3
	ξ-> 1/4*(1-ξ-ξ^2+ξ^3) 	ξ-> 1/4*(-1-ξ+ξ^2+ξ^3)
]

# ╔═╡ 0ba5b17f-1363-45cd-a2ac-75ee3e05c912
xᵢ(i) = Δx*(i-1)

# ╔═╡ aaec9e92-7c8f-4c7c-9755-3d3065ddc123
yⱼ(j) = Δy*(j-1)

# ╔═╡ b5a9bec7-d4a4-47a1-8ec0-b50098e42d36
# funkcja, która przyjmnie małe m oraz wypluje czerwony. el + lok - > glob.

# ╔═╡ 7248ef70-f4e0-4039-936b-bf8c20887a49
function get_grid2()
	els = m(nx-1, ny-1)
	number_of_nodes = nx*ny
	xs = x_range |> collect
	ys = y_range |> collect
	X_n = zeros(M, 4)
	Y_n = zeros(M, 4)
	N_n = zeros(Int, M, 4)
	for i in 1:nx-1, j in 1:ny-1
		current_element = m(i,j)
		
		# lewy dolny
		X_n[current_element, 1] = xs[i]
		Y_n[current_element, 1] = ys[j]
		N_n[current_element, 1] = i+(j-1)*nx

		# prawy dolny
		X_n[current_element, 2] = xs[i+1]
		Y_n[current_element, 2] = ys[j]
		N_n[current_element, 2] = i+1+(j-1)*nx

		# prawy górny
		X_n[current_element, 3] = xs[i+1]
		Y_n[current_element, 3] = ys[j+1]
		N_n[current_element, 3] = i+1+j*nx

		# lewy górny
		X_n[current_element, 4] = xs[i]
		Y_n[current_element, 4] = ys[j+1]
		N_n[current_element, 4] = i+j*nx
	end

	X_n, Y_n, N_n
end

# ╔═╡ 505454a6-a8d2-43d7-9678-c1ae69874bdc
function get_grid(p::Params)
	M = get_M(p)
	xs = x_range(p) |> collect
	ys = y_range(p) |> collect
	X_n = [zeros(4) for element in 1:M]
	Y_n = [zeros(4) for element in 1:M]
	N_n = [zeros(Int, 4) for element in 1:M]
	for i in 1:p.nx-1, j in 1:p.ny-1
		current_element = get_m(i,j, p)
		# Węzły (rogi kwadratu):
		# lewy dolny
		X_n[current_element][1] = xs[i]
		Y_n[current_element][1] = ys[j]
		N_n[current_element][1] = i+(j-1)*p.nx

		# prawy dolny
		X_n[current_element][2] = xs[i+1]
		Y_n[current_element][2] = ys[j]
		N_n[current_element][2] = i+1+(j-1)*p.nx

		# prawy górny
		X_n[current_element][3] = xs[i+1]
		Y_n[current_element][3] = ys[j+1]
		N_n[current_element][3] = i+1+j*p.nx

		# lewy górny
		X_n[current_element][4] = xs[i]
		Y_n[current_element][4] = ys[j+1]
		N_n[current_element][4] = i+j*p.nx
	end

	X_n, Y_n, N_n
end

# ╔═╡ 29e90667-ed82-4267-aa2b-8b22b56713ab
X, Y, N = get_grid(Params(3, 3))

# ╔═╡ 438ae6eb-7853-4542-a52a-405da992954b
md"## Zad1"

# ╔═╡ 3c08f21a-ca09-4605-9b14-d47e5d0258c1
function plot_grid()
	X, Y, N = get_grid(Params(3,3))
	p = scatter()
	for i in 1:4
		p = scatter!(p, X[i].+π*0.005*i, Y[i], jitter=0.3, label="Element $i")
	end
	plot!(p, title="Grid")
end

# ╔═╡ 42eb87f7-9c7e-45e8-905c-7142004ed5ae
plot_grid()

# ╔═╡ a6666bb4-e68c-4913-ab26-c30aeb2a2ffc
md"## Zad2"

# ╔═╡ d0c50886-b37f-4530-85a6-cfb00828ba62
get_N_max(p::Params) = 4*p.nx*p.ny

# ╔═╡ c8d5982a-8806-43a8-9e6d-bcd1197197be
first_derivative(g, dx = 1e-6) = x->(g(x+dx)-g(x-dx))/2dx

# ╔═╡ 1bd934bb-98c7-4667-8f27-ba5276aebb38
second_derivative(g) = x->first_derivative(first_derivative(g))(x)

# ╔═╡ 4c953f77-b478-4e1d-bd1a-62efee4dceff
function Integrate(fnc;n=20)
	nodes, weights = gausslegendre(n)
	return weights .* fnc.(nodes) |> sum
end

# ╔═╡ 4b0d5f67-40bb-4e72-806c-dd2dcd225cdd
function Integrate2D(fnc; n=20)
	return Integrate(
		x->Integrate(y->fnc(x,y))
	)
end

# ╔═╡ 0282fe4c-ad7d-43d7-8ad6-aebe1caf4b7d
Integrate2D((x,y)->x^2+y^2, n=20) ≈ 8/3 # Zgadza się

# ╔═╡ 0a803dd5-fbe5-4320-ae31-649fb7a58ea1
Jm(m, x, y) = (x[m][2] - x[m][1])*(y[m][4]-y[m][1])/4 

# ╔═╡ e873d58a-ad01-4476-958b-2a85fe098c01
w = [
	(ξ1, ξ2) -> (1-ξ1)*(1-ξ2)/4
	(ξ1, ξ2) -> (1+ξ1)*(1-ξ2)/4
	(ξ1, ξ2) -> (1+ξ1)*(1+ξ2)/4
	(ξ1, ξ2) -> (1-ξ1)*(1+ξ2)/4
]

# ╔═╡ c633287e-b803-4f79-a595-11e7fe9d3d09
function get_var(ξ1, ξ2, m, arr)
	val = 0
	for i in 1:4
		val = val + arr[m][i]*w[i](ξ1, ξ2)
	end
	val
end

# ╔═╡ b8726022-414e-4b0f-b599-6bfcd82b11bb
function p(i,j)
	current_m = m(i,j)
	return 4*(n(current_m, 1) - 1) + i+1+2i
end

# ╔═╡ 044864ff-213f-4cc6-b429-5074cf8c8263
ρ(x,y) = -sin(2y)*sin(x)^2

# ╔═╡ 651e678e-6471-4a6b-80bf-4d3d57538ff8
function Spq(X_n, Y_n, N_n, p::Params)
	n_max = get_N_max(p)
	M = get_M(p)
	# for each element and each node in element:
	spq = zeros(n_max, n_max)
	# g(α1, β1, α2, β2, i1, i2, j1, j2) = (ξ1, ξ2)->(
	# 		ϕ[i1,α1](ξ1) *
	# 		ϕ[i2,β1](ξ2) *
	# 		(second_derivative(ϕ[j1,α2])(ξ1) * ϕ[j2,β2](ξ2) +
	# 		ϕ[j1,α2](ξ1) * second_derivative(ϕ[j2,β2])(ξ2) )
	# 	)
	# @avx for m in 1:M, l1 in 1:4, i1 in 1:2, i2 in 1:2, l2 in 1:4, j1 in 1:2, j2 in 1:2
	# 	# x(ξ1, ξ2) = get_var(ξ1, ξ2, m, X_n)
	# 	# y(ξ1, ξ2) = get_var(ξ1, ξ2, m, X_n)
	# 	α1, β1 = get_l[l1]
	# 	α2, β2 = get_l[l2]

	# 	p = 4*(N_n[m][l1]-1) + (i1-1)+1+2*(i2-1)
	# 	q = 4*(N_n[m][l2]-1) + (j1-1)+1+2*(j2-1)
		
	# 	# g(ξ1, ξ2) = (
	# 	# 	ϕ[i1,α1](ξ1) *
	# 	# 	ϕ[i2,β1](ξ2) *
	# 	# 	(second_derivative(ϕ[j1,α2])(ξ1) * ϕ[j2,β2](ξ2) +
	# 	# 	ϕ[j1,α2](ξ1) * second_derivative(ϕ[j2,β2])(ξ2) )
	# 	# )
		
	# 	spq[p,q] = spq[p,q]+Integrate2D(
	# 		g(α1, β1, α2, β2, i1, i2, j1, j2)
	# 	)
	# end
	@inbounds for m in 1:M, l1 in 1:4, i1 in 1:2, i2 in 1:2, l2 in 1:4, j1 in 1:2, j2 in 1:2
		α1, β1 = get_l[l1]
		α2, β2 = get_l[l2]

		p = 4*(N_n[m][l1]-1) + (i1-1)+1+2*(i2-1)
		q = 4*(N_n[m][l2]-1) + (j1-1)+1+2*(j2-1)
		
		g(ξ1, ξ2) = (
			ϕ[i1,α1](ξ1) *
			ϕ[i2,β1](ξ2) *
			(second_derivative(ϕ[j1,α2])(ξ1) * ϕ[j2,β2](ξ2) +
			ϕ[j1,α2](ξ1) * second_derivative(ϕ[j2,β2])(ξ2) )
		)
		
		spq[p,q] = spq[p,q]+Integrate2D(g)
	end
	spq
end

# ╔═╡ 14497054-ee71-4a45-9369-05d068b3dc4f
spq = Spq(X,Y,N, Params(3,3))

# ╔═╡ 4b25b5b3-d47f-47b0-a54a-057b58ac5aaf
function Fp(X_n, Y_n, N_n, p::Params)
	n_max = get_N_max(p)
	M = get_M(p)
	fp = zeros(n_max)
	# for each element and each node in element:
	for m in 1:M, l in 1:4, i1 in 1:2, i2 in 1:2
		x = (ξ1, ξ2)->get_var(ξ1, ξ2, m, X_n)
		y = (ξ1, ξ2)->get_var(ξ1, ξ2, m, Y_n)
		α, β = get_l[l]
		g(ξ1, ξ2) = (
			ϕ[i1,α](ξ1) *
			ϕ[i2,β](ξ2) *
			ρ(x(ξ1, ξ2), y(ξ1, ξ2)) *
			Jm(m, X_n, Y_n) *
			(-1)
		)
		
		p = 4*(N_n[m][l]-1)+(i1-1)+1+2*(i2-1)
		fp[p] = fp[p]+Integrate2D(g)
	end
	fp
end

# ╔═╡ 48d2b7ee-e523-45e0-9e69-f7372816f9e8
fp = Fp(X, Y, N, Params(3,3))

# ╔═╡ 05a1ce9c-4092-428c-a700-811509e300c2
function WB(S_pq, F_p, X_n, Y_n, N_n, p::Params)
	n_max = get_N_max(p)
	M = get_M(p)
	j = 1:n_max
	S = copy(S_pq)
	F = copy(F_p)
	for m in 1:M, l in 1:4, i1 in 0:1, i2 in 0:1
		if (X_n[m][l] ≈ 0 || X_n[m][l] ≈ π || Y_n[m][l] ≈ 0 || Y[m][l] ≈ π) && 	(i1==0 || i2 == 0)
			p = 4*(N_n[m][l]-1)+i1+1+2*(i2)
			S[p,:] .= 0
			S[:,p] .= 0 
			S[p,p] = 1
			F[p] = 0
			@show (p,p)
		end
			
	end
	S, F
end

# ╔═╡ a8e9a31e-ff63-441e-9c80-ecae4cd66611


# ╔═╡ 53820b31-59b7-463f-b2bc-c358cf5bcb33
spq

# ╔═╡ 272b5485-cd67-4cd3-8b7f-dc1f9048dc3a
s1, f1 = WB(spq, fp, X, Y, N, Params(3,3))

# ╔═╡ d8aca9f5-fab0-47f7-b13b-a7c32cc5710c
f1

# ╔═╡ 01ac5216-b256-4ebb-83cd-7777b882185e
s1

# ╔═╡ 0f2b90b7-283e-4e58-a9c8-1a3378734f99
X[2][1] ≈ π

# ╔═╡ ac755131-0143-4b55-94a7-c5c4c5584ffe
s1\f1

# ╔═╡ 6ba6fb74-2510-4a95-a6ee-6467328c883d
function get_u()
	u = 0
	for m in 1:M, l in 1:4, i1 in 0:1, i2 in 0:1
		u = u + c[]
	end
end

# ╔═╡ ca92053d-5614-4a1e-8685-126e8ca557cb
function RayRitz(S, C, F)
	a1 = 0
	a2 = 0
	n_max = length(F)
	for i in 1:n_max, j in 1:n_max
		a1 = a1+(-1)*C[i]*C[j]*S[i,j]/2
	end
	for i in 1:n_max
		a2 = a2 + C[i]*F[i]
	end

	return a1 + a2
end

# ╔═╡ a8a92720-7b49-43ac-9e74-c903580ffe8a
function solve(p::Params)
	X, Y, N = get_grid(p)
	spq = Spq(X,Y,N, p)
	fp = Fp(X, Y, N, p)

	s1, f1 = WB(spq, fp, X, Y, N, Params(3,3))
	c = s1\f1
	return s1, c, f1
end

# ╔═╡ 3c2588ed-ff64-4571-bb9d-e3f6c60259aa
function save_outcomes(s, c, f)
	n_max = length(f)
	nx = Int(√(n_max/4))
	mkpath("data")
	writedlm("data/S$nx.dat", s)
	writedlm("data/C$nx.dat", c)
	writedlm("data/F$nx.dat", f)
end

# ╔═╡ a2969214-bbbe-4970-92b6-5f954ccdbd31
md"## nx = ny = 3"

# ╔═╡ 18bef389-e462-4f74-b8d1-fed2a5a3b8e2
S3, C3, P3 = solve(Params(3,3))

# ╔═╡ 637798d7-ad63-450e-80d6-cb853a9ea5a5
RayRitz(S3, C3, P3)

# ╔═╡ 35c6aa03-27af-4f79-807a-2107a4a35056
save_outcomes(S3, C3, P3)

# ╔═╡ b1175f99-4221-422c-b191-2756427a40a8
md"## nx = ny = 5"

# ╔═╡ f17acaea-5d01-48b9-b66c-714b578fbb67
S5, C5, P5 = solve(Params(5,5))

# ╔═╡ 9ae09ff5-d92d-4afb-86eb-f8c6396d2ef6
save_outcomes(S5, C5, P5)

# ╔═╡ 8f0b5318-1ff6-41e0-a3ea-497278f41304
RayRitz(S5, C5, P5)

# ╔═╡ 012f0af3-d62f-4dac-a21c-56969ac0cbdb
md"## nx = ny = 15"

# ╔═╡ af301ff1-29d1-4d9f-84a4-fb121d5107df
md"# Wykresy konturowe"

# ╔═╡ 536b336b-6baf-45f8-b603-ecd538221da2
udok(x,y) = sin(2y)*(
	1/16 * ℯ^(2x)*(ℯ^(-2π)-1) / (ℯ^(2π) - ℯ^(-2π))
	-1/16 * ℯ^(-2x)*(ℯ^(2π)-1) / (ℯ^(2π) - ℯ^(-2π))
	+1/8 -1/16*cos(2x)
)

# ╔═╡ 95952c81-4e6a-4ed6-a81e-152ad528565f
Z = map(udok, 0:0.1:π, 0:0.1:π)

# ╔═╡ 2c18a38e-acf5-43db-bfe8-7b3d6ae9dfd7
p1 = contour(0:0.1:π,  0:0.1:π, udok, fill=true, title="Dokładne rozwiązanie")

# ╔═╡ 5bec0d8e-72de-4090-92ee-b17c7a1f1ade
function u_num(X, Y, C)
	fnc = (x, y) -> begin
		val = 0
		p = Params(3,3)
		Δx = Δy = get_Δx(p)
		i = x/Δx +1 |> ceil |> Int
		j = y/Δy +1 |> ceil |> Int
		m = get_m(i,j, p)
		for l in 1:4, i1 in 0:1, i2 in 0:1
			ξ1 = (x - (X[m][1]+X[m][2])/2)*2/(X[m][2]-X[m][1])
			ξ2 = (y - (Y[m][1]+Y[m][4])/2)*2/(Y[m][4]-Y[m][1])
	
			α, β = get_l[l]
			p = 4*(N[m][l]-1) + i1+1 + 2i2
			val = val + C[p] * ϕ[i1,α](ξ1) * ϕ[i2, β](ξ2)
		end
		val
	end
	return fnc
end

# ╔═╡ 00b843b5-63c2-40f5-9dbc-7ab30cdde5a5
u_num(X, Y, X)(3,3)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"
FastGaussQuadrature = "442a2c76-b920-505d-bb47-c5924d526838"
LoopVectorization = "bdcacae8-1622-11e9-2a5c-532679323890"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[compat]
FastGaussQuadrature = "~0.4.7"
LoopVectorization = "~0.12.98"
Plots = "~1.23.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "e527b258413e0c6d4f66ade574744c94edef81f8"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.40"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BitTwiddlingConvenienceFunctions]]
deps = ["Static"]
git-tree-sha1 = "bc1317f71de8dce26ea67fcdf7eccc0d0693b75b"
uuid = "62783981-4cbd-42fc-bca8-16325de8dc4b"
version = "0.1.1"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CPUSummary]]
deps = ["Hwloc", "IfElse", "Static"]
git-tree-sha1 = "87b0c9c6ee0124d6c1f4ce8cb035dcaf9f90b803"
uuid = "2a0fbf3d-bb9c-48f3-b0a9-814d99fd7ab9"
version = "0.1.6"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f885e7e7c124f8c92650d61b9477b9ac2ee607dd"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.1"

[[CloseOpenIntervals]]
deps = ["ArrayInterface", "Static"]
git-tree-sha1 = "7b8f09d58294dc8aa13d91a8544b37c8a1dcbc06"
uuid = "fb6a15b2-703c-40df-9091-08a04967cfa9"
version = "0.1.4"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "3287dacf67c3652d3fed09f4c12c187ae4dbb89a"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.4.0"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FastGaussQuadrature]]
deps = ["LinearAlgebra", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "5829b25887e53fb6730a9df2ff89ed24baa6abf6"
uuid = "442a2c76-b920-505d-bb47-c5924d526838"
version = "0.4.7"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "6406b5112809c08b1baa5703ad274e1dded0652f"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.23"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "30f2b340c2fff8410d89bfcdc9c0a6dd661ac5f7"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.62.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "fd75fa3a2080109a2c0ec9864a6e14c60cca3866"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.62.0+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7bf67e9a481712b3dbe9cb3dac852dc4b1162e02"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+0"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[HostCPUFeatures]]
deps = ["BitTwiddlingConvenienceFunctions", "IfElse", "Libdl", "Static"]
git-tree-sha1 = "8f0dc80088981ab55702b04bba38097a44a1a3a9"
uuid = "3e5b6fbb-0976-4d2c-9146-d79de83f2fb0"
version = "0.1.5"

[[Hwloc]]
deps = ["Hwloc_jll"]
git-tree-sha1 = "92d99146066c5c6888d5a3abc871e6a214388b91"
uuid = "0e44f5e4-bd66-52a0-8798-143a42290a1d"
version = "2.0.0"

[[Hwloc_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3395d4d4aeb3c9d31f5929d32760d8baeee88aaf"
uuid = "e33a78d0-f292-5ffc-b300-72abe9b543c8"
version = "2.5.0+0"

[[IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LayoutPointers]]
deps = ["ArrayInterface", "LinearAlgebra", "ManualMemory", "SIMDTypes", "Static"]
git-tree-sha1 = "83b56449c39342a47f3fcdb3bc782bd6d66e1d97"
uuid = "10f19ff3-798f-405d-979b-55457f8fc047"
version = "0.1.4"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "6193c3815f13ba1b78a51ce391db8be016ae9214"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.4"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[LoopVectorization]]
deps = ["ArrayInterface", "CPUSummary", "CloseOpenIntervals", "DocStringExtensions", "HostCPUFeatures", "IfElse", "LayoutPointers", "LinearAlgebra", "OffsetArrays", "PolyesterWeave", "Requires", "SIMDDualNumbers", "SLEEFPirates", "Static", "ThreadingUtilities", "UnPack", "VectorizationBase"]
git-tree-sha1 = "9d8ce46c7727debdfd65be244f22257abf7d8739"
uuid = "bdcacae8-1622-11e9-2a5c-532679323890"
version = "0.12.98"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[ManualMemory]]
git-tree-sha1 = "9cb207b18148b2199db259adfa923b45593fe08e"
uuid = "d125e4d3-2237-4719-b19c-fa641b8a4667"
version = "0.1.6"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun"]
git-tree-sha1 = "7dc03c2b145168f5854085a16d054429d612b637"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.23.5"

[[PolyesterWeave]]
deps = ["BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "Static", "ThreadingUtilities"]
git-tree-sha1 = "a3ff99bf561183ee20386aec98ab8f4a12dc724a"
uuid = "1d0040c9-8b98-4ee7-8388-3f51789ca0ad"
version = "0.1.2"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SIMDDualNumbers]]
deps = ["ForwardDiff", "IfElse", "SLEEFPirates", "VectorizationBase"]
git-tree-sha1 = "62c2da6eb66de8bb88081d20528647140d4daa0e"
uuid = "3cdde19b-5bb0-4aaf-8931-af3e248e098b"
version = "0.1.0"

[[SIMDTypes]]
git-tree-sha1 = "330289636fb8107c5f32088d2741e9fd7a061a5c"
uuid = "94e857df-77ce-4151-89e5-788b33177be4"
version = "0.1.0"

[[SLEEFPirates]]
deps = ["IfElse", "Static", "VectorizationBase"]
git-tree-sha1 = "1410aad1c6b35862573c01b96cd1f6dbe3979994"
uuid = "476501e8-09a2-5ece-8869-fb82de89a1fa"
version = "0.6.28"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "f0bccf98e16759818ffc5d97ac3ebf87eb950150"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "e7bc80dc93f50857a5d1e3c8121495852f407e6a"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.4.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[ThreadingUtilities]]
deps = ["ManualMemory"]
git-tree-sha1 = "03013c6ae7f1824131b2ae2fc1d49793b51e8394"
uuid = "8290d209-cae3-49c0-8002-c8c24d57dab5"
version = "0.4.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[VectorizationBase]]
deps = ["ArrayInterface", "CPUSummary", "HostCPUFeatures", "Hwloc", "IfElse", "LayoutPointers", "Libdl", "LinearAlgebra", "SIMDTypes", "Static"]
git-tree-sha1 = "5239606cf3552aff43d79ecc75b1af1ce4625109"
uuid = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"
version = "0.21.21"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╠═2a08a1f7-4a60-49b3-abd0-fa243bdcae79
# ╠═7026f9c4-40a9-11ec-1568-3b997fceb607
# ╠═dd81b82b-13ac-4b10-8746-6c1901d24d7c
# ╠═c22e5519-6054-4eef-81b7-4907809b6e87
# ╠═be5564c1-ed0d-4732-8215-e016c2cbc5aa
# ╠═d760ffc2-de02-416e-b24a-065af382db42
# ╠═cb5a6eb8-f350-426b-b06d-8c3d6eac2447
# ╠═389ce350-5c42-459b-9d27-ecf00cf69712
# ╠═8748750f-1863-4ddc-ad05-c65409e95d43
# ╠═9df918b6-e1b5-458d-98c3-4334918d2d5d
# ╠═68b5857f-3699-4014-9f0d-f61dbca894f9
# ╠═4aa5d20f-704f-4b0d-92a6-5dd87fa2634e
# ╠═0ba5b17f-1363-45cd-a2ac-75ee3e05c912
# ╠═aaec9e92-7c8f-4c7c-9755-3d3065ddc123
# ╠═b5a9bec7-d4a4-47a1-8ec0-b50098e42d36
# ╠═7248ef70-f4e0-4039-936b-bf8c20887a49
# ╠═505454a6-a8d2-43d7-9678-c1ae69874bdc
# ╠═29e90667-ed82-4267-aa2b-8b22b56713ab
# ╟─438ae6eb-7853-4542-a52a-405da992954b
# ╠═3c08f21a-ca09-4605-9b14-d47e5d0258c1
# ╠═42eb87f7-9c7e-45e8-905c-7142004ed5ae
# ╟─a6666bb4-e68c-4913-ab26-c30aeb2a2ffc
# ╠═d0c50886-b37f-4530-85a6-cfb00828ba62
# ╠═c8d5982a-8806-43a8-9e6d-bcd1197197be
# ╠═1bd934bb-98c7-4667-8f27-ba5276aebb38
# ╠═4c953f77-b478-4e1d-bd1a-62efee4dceff
# ╠═4b0d5f67-40bb-4e72-806c-dd2dcd225cdd
# ╠═0282fe4c-ad7d-43d7-8ad6-aebe1caf4b7d
# ╠═0a803dd5-fbe5-4320-ae31-649fb7a58ea1
# ╠═e873d58a-ad01-4476-958b-2a85fe098c01
# ╠═c633287e-b803-4f79-a595-11e7fe9d3d09
# ╠═b8726022-414e-4b0f-b599-6bfcd82b11bb
# ╠═044864ff-213f-4cc6-b429-5074cf8c8263
# ╠═651e678e-6471-4a6b-80bf-4d3d57538ff8
# ╠═14497054-ee71-4a45-9369-05d068b3dc4f
# ╠═4b25b5b3-d47f-47b0-a54a-057b58ac5aaf
# ╠═48d2b7ee-e523-45e0-9e69-f7372816f9e8
# ╠═05a1ce9c-4092-428c-a700-811509e300c2
# ╠═a8e9a31e-ff63-441e-9c80-ecae4cd66611
# ╠═53820b31-59b7-463f-b2bc-c358cf5bcb33
# ╠═272b5485-cd67-4cd3-8b7f-dc1f9048dc3a
# ╠═d8aca9f5-fab0-47f7-b13b-a7c32cc5710c
# ╠═01ac5216-b256-4ebb-83cd-7777b882185e
# ╠═0f2b90b7-283e-4e58-a9c8-1a3378734f99
# ╠═ac755131-0143-4b55-94a7-c5c4c5584ffe
# ╠═6ba6fb74-2510-4a95-a6ee-6467328c883d
# ╠═ca92053d-5614-4a1e-8685-126e8ca557cb
# ╠═a8a92720-7b49-43ac-9e74-c903580ffe8a
# ╠═3c2588ed-ff64-4571-bb9d-e3f6c60259aa
# ╟─a2969214-bbbe-4970-92b6-5f954ccdbd31
# ╠═18bef389-e462-4f74-b8d1-fed2a5a3b8e2
# ╠═637798d7-ad63-450e-80d6-cb853a9ea5a5
# ╠═35c6aa03-27af-4f79-807a-2107a4a35056
# ╟─b1175f99-4221-422c-b191-2756427a40a8
# ╠═f17acaea-5d01-48b9-b66c-714b578fbb67
# ╠═9ae09ff5-d92d-4afb-86eb-f8c6396d2ef6
# ╠═8f0b5318-1ff6-41e0-a3ea-497278f41304
# ╟─012f0af3-d62f-4dac-a21c-56969ac0cbdb
# ╟─af301ff1-29d1-4d9f-84a4-fb121d5107df
# ╠═95952c81-4e6a-4ed6-a81e-152ad528565f
# ╠═536b336b-6baf-45f8-b603-ecd538221da2
# ╠═2c18a38e-acf5-43db-bfe8-7b3d6ae9dfd7
# ╠═5bec0d8e-72de-4090-92ee-b17c7a1f1ade
# ╠═00b843b5-63c2-40f5-9dbc-7ab30cdde5a5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
