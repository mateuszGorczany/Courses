### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ f4934dfe-4629-11ec-1c4d-e9835efaf5c0
begin
	using Plots
	using OffsetArrays
	using LinearAlgebra
	using StaticArrays
end

# ╔═╡ db586196-ade6-4821-b9ba-ab321a9e40b9
begin
	const N = 100
	const x_min = y_min = -5
	const x_max = y_max = 5
	const Lx = 10.0
	const Ly = 10.0

	const ksi1 = [
    -0.333333333333333,
    -0.059715871789770,
    -0.059715871789770,
    -0.880568256420460,
    -0.797426985353088,
    -0.797426985353088,
     0.594853970706174
	 ]

  	const ksi2 = [
    -0.333333333333333,
    -0.059715871789770,
    -0.880568256420460,
    -0.059715871789770,
    -0.797426985353088,
     0.594853970706174,
    -0.797426985353088
  ]

  	const weight = [
    0.450000000000000,
    0.264788305577012,
    0.264788305577012,
    0.264788305577012,
    0.251878361089654,
    0.251878361089654,
    0.251878361089654
  ]

end

# ╔═╡ c16c29e6-4d0f-408e-8495-2330c6eee421
# najpierw robimy zwykłąd tablicę 2d - siatkę węzłów (kwadratów)
# potem łączymy je w elementy - łączanie elementów musi być w tym samym kierunku

# ╔═╡ 1a6b3eba-516e-44ba-9f25-90ef3229ab0d
ϕ = [
	(ζ, η) -> -1/2*(η+ζ)
	(ζ, η) -> 1/2*(1+ζ)
	(ζ, η) -> 1/2*(1+η)
]

# ╔═╡ 56419d47-6311-4247-bb49-9d27f0a88738
first_derivative(g, dx = 1e-6) = x->(g(x+dx)-g(x-dx))/2dx

# ╔═╡ dd991677-c576-42db-8b34-d2eb7578b47c
second_derivative(g) = x->first_derivative(first_derivative(g))(x)

# ╔═╡ faa13eca-0d28-43cb-b805-96f08234522f
ρ(x,y) = exp(-1/2*(x^2+y^2))

# ╔═╡ 06bdc586-3ca9-4333-847f-77de7f6ec01a
# macierze mają być symetryczne.

# ╔═╡ abeb7502-b6df-4e8a-a172-7fe5c4e87f54
# wektor obciążeń: całkowanie po trójkącie

# ╔═╡ 0291f0d7-1ee1-4e6c-b6e2-36be36bba881
struct Element
	local_node::SVector{3,Int}
end

# ╔═╡ ab1badc8-7f58-44cb-8449-c710cb9a6b6e
Node = Tuple{Float64, Float64}

# ╔═╡ 291694cc-0819-448f-bc49-7dc26094f90c
Elements = Vector{Element}

# ╔═╡ 6f525369-cc11-475b-9629-441c6f05897e
OElements = OffsetVector{Element}

# ╔═╡ 36f2fdc4-e485-4034-8a2d-0a8f32f1e03f
ONodes = OffsetVector{Node}

# ╔═╡ 88f07d32-d991-492b-9551-314ef4a74dec
Nodes = Vector{Node}

# ╔═╡ 7cb216a0-e849-4e6e-af4f-f18b0eef7f37
offsetize(x) = OffsetArray(x, 0:length(x)-1)

# ╔═╡ 32ad4578-c4af-4ba3-8790-f4351d5b2c44
OffsetArray(Nodes([(1,2),(3,4)]))

# ╔═╡ cc40f6e3-c2a1-434c-b59e-3461480266cd
Nodes()

# ╔═╡ 14ccf815-8b63-4204-b6df-dc35e1462b53
function create_nodes(Nx::Int, Ny::Int)
	nodes = Nodes()
	dx = Lx/(Nx-1)
	dy = Ly/(Ny-1)
	for i in 0:Nx-1, j in 0:Ny-1
		x = -Lx/2 + i*dx
		y = -Lx/2 + j*dy

		push!(nodes, (x,y))
	end
	nodes
end

# ╔═╡ f2c573d8-7148-4c9e-9e72-9fa22a023699
create_onodes(Nx::Int, Ny::Int) = create_nodes(Nx, Ny) |> offsetize

# ╔═╡ f1b03cdb-ba0e-44b6-ac7d-0c4b14fb9711
create_onodes(3,3)

# ╔═╡ 49bb48ac-735a-438b-91ff-0147b65e0cb6
function create_elements(Nx::Int, Ny::Int)
	n = 0
	# elements = Elements()
	# elements = OffsetVector(Elements(), 0:Nx*Ny)
	elements = Elements()
	for i in 0:Nx-2
		for j in 0:Ny-2
		element1 = Element([n, n+1, n+Nx])
		element2 = Element([n+1, n+1+Nx, n+Nx])
		push!(elements, element1)
		push!(elements, element2)
		n = n+1
		end
		n = n+1
	end
	elements
end

# ╔═╡ 074d7eb1-5548-426a-91e3-476b4cd63e53
create_oelements(Nx::Int, Ny::Int) = create_elements(Nx, Ny) |> offsetize

# ╔═╡ 9308e26c-ad9e-4c8c-b1a9-45fb2d17d35b
nodes3x3 = create_onodes(3,3)

# ╔═╡ 6fa3fb28-c410-4988-9252-9176e2202311
elements3x3 = create_oelements(3,3)

# ╔═╡ 75e0574e-6b6f-4e98-b143-616f4f2c755d
let 
struct Grid
	nodes::ONodes
	elements::OElements
	shape
end
Grid(Nx::Int, Ny::Int) = Grid(
		create_onodes(Nx,Ny), 
		create_oelements(Nx, Ny),
		(Nx,Ny)
	)
end

# ╔═╡ 1852b6f5-687a-45e2-a200-4dd139c0b19b
function get_triangle_cords(cgrid::Grid, index)
	(
		cgrid.nodes[cgrid.elements[index].local_node[1]],
		cgrid.nodes[cgrid.elements[index].local_node[2]],
		cgrid.nodes[cgrid.elements[index].local_node[3]]
	)
end

# ╔═╡ 3778b18a-7ae2-4463-b713-6af40e521427
Grid(3,3)

# ╔═╡ 4533b854-fbf5-4a1f-91c4-968a3bbfa4a3
get_triangle_cords(Grid(3,3), 0)

# ╔═╡ 40c8b0cf-c7b5-4baf-b04d-141198579b63
function print_elements(elements, nodes)
	@show "AHTUNG ASDFADSF"
	for element in elements
		@show nodes[element.local_node[1]]
		@show nodes[element.local_node[2]]
		@show nodes[element.local_node[3]]
		@show "\n"
		@show "\n"
	end
end

# ╔═╡ 8d2a1dfa-3fdc-4a97-9586-9052dfb34a7a
get_cords_right(p1, p2) = ([p1[1], p2[1]], [p1[2], p2[2]])

# ╔═╡ f4667179-5332-49f7-bcca-a7ecf6b0d959
function plt!(s, grd, index)	
	p1, p2, p3 = get_triangle_cords(grd, index)
	p = s
	plot!(p, get_cords_right(p1,p2)..., legend=false)
	plot!(p, get_cords_right(p2,p3)..., legend=false)
	plot!(p, get_cords_right(p3,p1)..., legend=false)

	return p
end

# ╔═╡ 25546d1a-2a29-47b8-a7a0-08729bc7659b
const GRID = Grid(10,10)

# ╔═╡ bb2f5c5c-b0cc-40ac-adc5-7fd82de73eaf
get_triangle_cords(GRID, 7) 

# ╔═╡ ae8663b9-44bb-43e0-aef6-07437624dc52
function plot_grid(grd)
	s = scatter(grd.nodes, title="Siatka elementów", xlabel="x", ylabel="y")
	p=s
	for i in 0:length(grd.elements)-1
		p = plt!(p, GRID, i)
	end
	s
end

# ╔═╡ b5c13cd2-8d91-49fc-8fe2-126f4c2847fb
c = plot_grid(GRID)

# ╔═╡ 87ddf918-83eb-4e1b-9c3b-fb0053567034
length(GRID.nodes)

# ╔═╡ 5f72ac94-364c-4cd4-a42a-03622cbbb673
GRID

# ╔═╡ 3d173344-04f8-4a56-b5d9-b4bfe07af6b1
md"## Macierze sztywności"

# ╔═╡ 7d3ebee0-f250-497f-9fbe-a8be203b88c8
diff_central(u, Δx=0.001) = x->(u(x+Δx) - u(x-Δx))/2Δx

# ╔═╡ 55c648a9-dbd8-41b3-a919-fe8cd2aebfa0
diff2_central(u, Δx=0.001) = x->(u(x+Δx) -2u(x) + u(x-Δx))/Δx^2

# ╔═╡ 06dab46d-11a4-47a2-b77a-659a36d38089
function calculate_gradient()
	diff_central(ϕₖ)(x)*diff_central()
end

# ╔═╡ 23660aaf-c135-49ff-9002-d341cfd2f332
extract_coord(grid, index, var_n) = get_triangle_cords(GRID,1) .|> x->x[var_n]

# ╔═╡ d43a379b-a25a-40d7-b556-f2bf8c44aaa4
extract_x(grid, index) = extract_coord(grid, index, 1) |> collect

# ╔═╡ 4afb70b7-6644-4025-937e-60b71175223c
extract_y(grid, index) = extract_coord(grid, index, 2) |> collect

# ╔═╡ 22814804-53fc-4c75-b5cd-4a94d1790a60
extract_y(GRID, 1)

# ╔═╡ 56a67c10-ea26-4d49-8f7a-b6f2faa37a94
get_triangle_cords(GRID,1) .|> x->x[2]

# ╔═╡ 086e670f-0271-4600-863d-650e17218b24
function x_prim()
	for i in 1:3
		extract_y(GRID, 1) * ϕ[i]
	end
end

# ╔═╡ cd7868c8-b2ae-493d-b02d-5f3e9af9e958
dfdy(f, dy=0.001) = (x,y) -> (f(x,y+dy)-f(x, y-dy))/2dy

# ╔═╡ c78244f5-30b2-497b-9112-5a5a9918b563
dfdx(f, dx=0.001) = (x,y) -> (f(x+dx,y)-f(x-dx, y))/2dx

# ╔═╡ 65970d92-eb8e-4f5d-bc7f-cdceb01085e9
dfdy(ϕ[1])(1,1)

# ╔═╡ 6c117269-522b-47b2-8d21-15c71eb116df
dfdy(ϕ[3])(1,10)

# ╔═╡ fb0ec538-47c0-4234-be52-b494934cfd60


# ╔═╡ c6c8e1f2-8797-46f5-85cf-dbc9d2215eb1
function x_interpolated(grid_object, element_index, fncs=ϕ)
	xs = extract_x(GRID, element_index)
	res = []
	for i in 1:3
		push!(res, (ζ, η)->fncs[i](ζ, η)*xs[i])
	end
	return res
end

# ╔═╡ 37c566ce-0aba-46a0-82c5-4b2f608f4749
function y_interpolated(grid_object, element_index, fncs=ϕ)
	ys = extract_y(GRID, element_index)
	res = []
	for i in 1:3
		push!(res, (ζ, η)->fncs[i](ζ, η)*ys[i])
	end
	return res
end

# ╔═╡ e4a194ef-ec0f-4d16-9ba1-8ec8af58c35d
x_interpolated(GRID, 1)[2](-5,-5)

# ╔═╡ 8eb4e6f4-a4ff-4345-ab8b-c789e7214e61
y_interp(grid, index, fncs=ϕ) = (ζ, η)->(fncs .|> x->x(ζ, η)) .*extract_y(grid, index)

# ╔═╡ 5992163c-2d05-4d94-9858-7d4180586e40
x_interp(grid, index, fncs=ϕ) = (ζ, η)->(fncs .|> x->x(ζ, η)) .*extract_x(grid, index)

# ╔═╡ 334436b8-1ed3-47f4-a29e-79aecd94da1e
y_interp(GRID, 1)(-5,-5)

# ╔═╡ b708a625-d2ac-43f5-82c9-9c394c95d2e4
x_interp(GRID, 1)(-5,-5)

# ╔═╡ 5b985445-fa2b-485e-9ea8-9d35bd357858
ϕ[2](-5,-5)

# ╔═╡ c4e7a689-6b90-423b-a28b-4ea10973b691
extract_x(GRID, 1)

# ╔═╡ 880f2945-af91-4fa4-aabf-85dd6fa40045
dϕdn = dfdy.(ϕ)

# ╔═╡ 996282ab-0340-44d6-900c-29dcbc4d0c06
dϕdz = dfdx.(ϕ)

# ╔═╡ 3a4f9ac8-d525-4fa7-85b4-dcf48d9401f6
var_x(grid, index) = (ζ, η)->((ϕ .|> x->x(ζ, η)) .*extract_x(grid, index)) |> sum

# ╔═╡ ba8f772f-2d31-4d68-8c72-68d9bf2dd5fc
var_y(grid, index) = (ζ, η)->((ϕ .|> x->x(ζ, η)) .*extract_y(grid, index)) |> sum

# ╔═╡ 1104b645-da5c-4a51-8fea-e667fb99d71a
dxdz(grid, index) = (ζ, η)->((dϕdz .|> x->x(ζ, η)) .*extract_x(grid, index)) |> sum

# ╔═╡ e407635d-32ec-43c5-a3fc-7034ded94cd6
dxdn(grid, index) = (ζ, η)->((dϕdn .|> x->x(ζ, η)) .*extract_x(grid, index)) |> sum

# ╔═╡ 0605143e-8065-46f8-9ca9-985f328ae03b
dydz(grid, index) = (ζ, η)->((dϕdz .|> x->x(ζ, η)) .*extract_y(grid, index)) |> sum

# ╔═╡ d835a5e4-da52-49e8-af4e-0ad1cd7a625d
dydn(grid, index) = (ζ, η)->((dϕdn .|> x->x(ζ, η)) .*extract_y(grid, index)) |> sum

# ╔═╡ ef4a9eed-f566-48d7-8dc8-25e5902f8c40
function get_Jm(grid, index)
	return (ζ, η)->dxdz(grid, index)(ζ, η)*dydn(grid, index)(ζ, η) - dydz(grid, index)(ζ, η)*dxdn(grid, index)(ζ, η)
end

# ╔═╡ dd017ca9-2efc-4834-a96c-cc5987d9edd9
get_Jm(GRID,1)(1,1)

# ╔═╡ 4a9eb121-b71e-4cab-958c-d8e33d13ea00
md"### Ręcznie wyliczone, ζ = z, n = η"

# ╔═╡ ff6eeaa0-5f44-4084-b3c3-35d5cb61c367
dϕdz[3](10000,1000)

# ╔═╡ 474f509f-0b15-4ea0-9c3d-829d74b850b1
# W skrocie:
dϕdζ = [-1/2, 1/2, 0]

# ╔═╡ 8a327391-1ba6-42f4-8bd9-a27a460c87c6
dϕdη = [-1/2, 0, 1/2]

# ╔═╡ 51e8927c-ba29-405e-a4ac-ea3681a3b843
md"#### Porównanie:"

# ╔═╡ 18f4c5d3-6fe9-4baf-a0dc-4895de464694
dϕdz .|> x->x(100,-100)

# ╔═╡ df0f6ac8-34cf-49f7-97f8-18c517377a1c
dϕdn .|> x->x(100,-100)

# ╔═╡ d0675389-4d9f-46cc-9ef4-528bfc2a5f0a


# ╔═╡ 250a2cd2-8dff-4231-959a-a8e13e7ed2ca
dzdx(grid, index) = (ζ, η)->1/get_Jm(grid, index)(ζ, η) * dydn(grid,index)(ζ, η)

# ╔═╡ 4a569507-7455-436b-8572-8d93f1804aac
dzdy(grid, index) = (ζ, η)->1/get_Jm(grid, index)(ζ, η) * dxdn(grid,index)(ζ, η)*(-1)

# ╔═╡ eed89fae-9a4b-4a62-837e-06e23aecda6f
dndx(grid, index) = (ζ, η)->1/get_Jm(grid, index)(ζ, η) * dydz(grid,index)(ζ, η)*(-1)

# ╔═╡ 6aff1da9-4cb8-4e99-aa89-0b9211f6447e
dndy(grid, index) = (ζ, η)->1/get_Jm(grid, index)(ζ, η) * dxdz(grid,index)(ζ, η)

# ╔═╡ 3eba22d5-df05-47fb-b5ea-abcb045e3a41
∇ϕₖ(grid, index, k) =  [
	(ζ, η)->dϕdζ[k]*dzdx(grid,index)(ζ, η)+dϕdη[k]*dndx(grid,index)(ζ, η),
	(ζ, η)->dϕdζ[k]*dzdy(grid,index)(ζ, η)+dϕdη[k]*dndy(grid,index)(ζ, η)
]

# ╔═╡ 585c31f2-8f0b-44d2-afd4-a0441788b8e1
function integrateLQTTriangle(g)
	N = 7
	res = 0
	for i in 1:N
		res = res + g(ksi1[i], ksi2[i])*weight[i]
	end
	res
end

# ╔═╡ 4941b830-7327-48e5-b158-cbf0aef18474
function calculate_E(grid)
	n_elements = grid.elements |> length
	N_max = grid.shape[1]*grid.shape[2]
	E = OffsetArray(zeros(N_max, N_max), 0:N_max-1, 0:N_max-1)
	
	for m in 0:n_elements-1, i in 1:3, j in 1:3
		p = grid.elements[m].local_node[i]
		q = grid.elements[m].local_node[j]
		xi, yi = ∇ϕₖ(grid, m, i)
		xj, yj = ∇ϕₖ(grid, m, j)
		f = (ζ, η)->get_Jm(grid,m)(ζ, η)*(xi(ζ, η)*xj(ζ, η) + yi(ζ, η)*yj(ζ, η))
		E[p,q] = E[p,q] + integrateLQTTriangle(f)
	end
	return E
end

# ╔═╡ 1ea6d8e7-ab66-410d-8cfd-c18fcfe3ce04
function WB(E, F)
	F[0] = 0
	F[end] = 0
	E[0, :] .= 0
	E[end, :] .= 0
	for i in 0:size(E)[1]-1
		E[i,i] = 1
	end
	E, F
end

# ╔═╡ b011a72b-ada0-4c40-811e-892d87a0f493
function calculate_F(grid)
	n_elements = grid.elements |> length
	N_max = grid.shape[1]*grid.shape[2]
	F = OffsetArray(zeros(N_max), 0:N_max-1)
	for m in 0:n_elements-1, j in 1:3
		q = grid.elements[m].local_node[j]
		f = (ζ, η)->get_Jm(grid,m)(ζ, η)*(ϕ[j](ζ, η)*ρ(var_x(grid, m)(ζ, η), var_y(grid,m)(ζ, η)))
		F[q] = F[q]+integrateLQTTriangle(f)
	end
	F
end

# ╔═╡ 03cd53da-88f3-4c3c-a759-d65555c4f7e9
GRID.elements # Jest to 10 na 10

# ╔═╡ 95730e29-8fbc-49bf-b72e-8166623473b5
GRID.nodes

# ╔═╡ 23920264-2a3c-4390-ae89-3d8a24742673
E10 = calculate_E(GRID) 

# ╔═╡ e17beb35-f3b6-4166-b7ef-42b04fa8b7d4
F10 = calculate_F(GRID)

# ╔═╡ 7c50f877-c53d-4cfe-b529-95c874c4a109
E10wb, F10wb = WB(E10, F10) .|> OffsetArrays.no_offset_view

# ╔═╡ 933646d8-6b22-42d9-8909-2ae64c71b998
c10 = E10wb\F10wb

# ╔═╡ 1e3f2e6b-95b3-4c7a-bff6-d7b334f76903


# ╔═╡ 3aa84098-39c4-4e69-90ed-7311a9e623e1
## Grid 100x100

# ╔═╡ bd3458b3-7c92-4e08-aa84-d19bc26fa08b
grid100 = Grid(100,100)

# ╔═╡ 5693e529-6155-4631-8e93-f8c5fa87cb2f
E100 = calculate_E(grid100) 

# ╔═╡ 681a8b33-a237-4a59-be47-279e863675af
F100 = calculate_F(grid100)

# ╔═╡ 847c2633-497a-407b-810c-9855d75b1583
E100wb, F100wb = WB(E100, F100) .|> OffsetArrays.no_offset_view

# ╔═╡ 162e686a-a5a8-41f5-be21-1c8279b0ad12
c100 = E100wb\F100wb

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
OffsetArrays = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
OffsetArrays = "~1.10.8"
Plots = "~1.23.6"
StaticArrays = "~1.2.13"
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

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

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

[[ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "9a1d594397670492219635b35a3d830b04730d62"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.1"

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
git-tree-sha1 = "74ef6288d071f58033d54fd6708d4bc23a8b8972"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+1"

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
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

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
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

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
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

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

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

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
git-tree-sha1 = "0d185e8c33401084cab546a756b387b15f76720c"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.23.6"

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

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

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
# ╠═f4934dfe-4629-11ec-1c4d-e9835efaf5c0
# ╠═db586196-ade6-4821-b9ba-ab321a9e40b9
# ╠═c16c29e6-4d0f-408e-8495-2330c6eee421
# ╠═1a6b3eba-516e-44ba-9f25-90ef3229ab0d
# ╠═56419d47-6311-4247-bb49-9d27f0a88738
# ╠═dd991677-c576-42db-8b34-d2eb7578b47c
# ╠═faa13eca-0d28-43cb-b805-96f08234522f
# ╠═06bdc586-3ca9-4333-847f-77de7f6ec01a
# ╠═abeb7502-b6df-4e8a-a172-7fe5c4e87f54
# ╠═0291f0d7-1ee1-4e6c-b6e2-36be36bba881
# ╠═ab1badc8-7f58-44cb-8449-c710cb9a6b6e
# ╠═291694cc-0819-448f-bc49-7dc26094f90c
# ╠═6f525369-cc11-475b-9629-441c6f05897e
# ╠═36f2fdc4-e485-4034-8a2d-0a8f32f1e03f
# ╠═88f07d32-d991-492b-9551-314ef4a74dec
# ╠═7cb216a0-e849-4e6e-af4f-f18b0eef7f37
# ╠═32ad4578-c4af-4ba3-8790-f4351d5b2c44
# ╠═cc40f6e3-c2a1-434c-b59e-3461480266cd
# ╠═14ccf815-8b63-4204-b6df-dc35e1462b53
# ╠═f2c573d8-7148-4c9e-9e72-9fa22a023699
# ╠═f1b03cdb-ba0e-44b6-ac7d-0c4b14fb9711
# ╠═49bb48ac-735a-438b-91ff-0147b65e0cb6
# ╠═074d7eb1-5548-426a-91e3-476b4cd63e53
# ╠═9308e26c-ad9e-4c8c-b1a9-45fb2d17d35b
# ╠═6fa3fb28-c410-4988-9252-9176e2202311
# ╠═75e0574e-6b6f-4e98-b143-616f4f2c755d
# ╠═1852b6f5-687a-45e2-a200-4dd139c0b19b
# ╠═3778b18a-7ae2-4463-b713-6af40e521427
# ╠═4533b854-fbf5-4a1f-91c4-968a3bbfa4a3
# ╠═40c8b0cf-c7b5-4baf-b04d-141198579b63
# ╠═bb2f5c5c-b0cc-40ac-adc5-7fd82de73eaf
# ╠═8d2a1dfa-3fdc-4a97-9586-9052dfb34a7a
# ╠═f4667179-5332-49f7-bcca-a7ecf6b0d959
# ╠═ae8663b9-44bb-43e0-aef6-07437624dc52
# ╠═25546d1a-2a29-47b8-a7a0-08729bc7659b
# ╠═b5c13cd2-8d91-49fc-8fe2-126f4c2847fb
# ╠═87ddf918-83eb-4e1b-9c3b-fb0053567034
# ╠═5f72ac94-364c-4cd4-a42a-03622cbbb673
# ╠═3d173344-04f8-4a56-b5d9-b4bfe07af6b1
# ╠═7d3ebee0-f250-497f-9fbe-a8be203b88c8
# ╠═55c648a9-dbd8-41b3-a919-fe8cd2aebfa0
# ╠═06dab46d-11a4-47a2-b77a-659a36d38089
# ╠═23660aaf-c135-49ff-9002-d341cfd2f332
# ╠═d43a379b-a25a-40d7-b556-f2bf8c44aaa4
# ╠═4afb70b7-6644-4025-937e-60b71175223c
# ╠═22814804-53fc-4c75-b5cd-4a94d1790a60
# ╠═56a67c10-ea26-4d49-8f7a-b6f2faa37a94
# ╠═086e670f-0271-4600-863d-650e17218b24
# ╠═cd7868c8-b2ae-493d-b02d-5f3e9af9e958
# ╠═c78244f5-30b2-497b-9112-5a5a9918b563
# ╠═65970d92-eb8e-4f5d-bc7f-cdceb01085e9
# ╠═6c117269-522b-47b2-8d21-15c71eb116df
# ╠═fb0ec538-47c0-4234-be52-b494934cfd60
# ╠═c6c8e1f2-8797-46f5-85cf-dbc9d2215eb1
# ╠═37c566ce-0aba-46a0-82c5-4b2f608f4749
# ╠═e4a194ef-ec0f-4d16-9ba1-8ec8af58c35d
# ╠═8eb4e6f4-a4ff-4345-ab8b-c789e7214e61
# ╠═5992163c-2d05-4d94-9858-7d4180586e40
# ╠═334436b8-1ed3-47f4-a29e-79aecd94da1e
# ╠═b708a625-d2ac-43f5-82c9-9c394c95d2e4
# ╠═5b985445-fa2b-485e-9ea8-9d35bd357858
# ╠═c4e7a689-6b90-423b-a28b-4ea10973b691
# ╠═880f2945-af91-4fa4-aabf-85dd6fa40045
# ╠═996282ab-0340-44d6-900c-29dcbc4d0c06
# ╠═3a4f9ac8-d525-4fa7-85b4-dcf48d9401f6
# ╠═ba8f772f-2d31-4d68-8c72-68d9bf2dd5fc
# ╠═1104b645-da5c-4a51-8fea-e667fb99d71a
# ╠═e407635d-32ec-43c5-a3fc-7034ded94cd6
# ╠═0605143e-8065-46f8-9ca9-985f328ae03b
# ╠═d835a5e4-da52-49e8-af4e-0ad1cd7a625d
# ╠═ef4a9eed-f566-48d7-8dc8-25e5902f8c40
# ╠═dd017ca9-2efc-4834-a96c-cc5987d9edd9
# ╠═4a9eb121-b71e-4cab-958c-d8e33d13ea00
# ╠═ff6eeaa0-5f44-4084-b3c3-35d5cb61c367
# ╠═474f509f-0b15-4ea0-9c3d-829d74b850b1
# ╠═8a327391-1ba6-42f4-8bd9-a27a460c87c6
# ╠═51e8927c-ba29-405e-a4ac-ea3681a3b843
# ╠═18f4c5d3-6fe9-4baf-a0dc-4895de464694
# ╠═df0f6ac8-34cf-49f7-97f8-18c517377a1c
# ╠═d0675389-4d9f-46cc-9ef4-528bfc2a5f0a
# ╠═250a2cd2-8dff-4231-959a-a8e13e7ed2ca
# ╠═4a569507-7455-436b-8572-8d93f1804aac
# ╠═eed89fae-9a4b-4a62-837e-06e23aecda6f
# ╠═6aff1da9-4cb8-4e99-aa89-0b9211f6447e
# ╠═3eba22d5-df05-47fb-b5ea-abcb045e3a41
# ╠═585c31f2-8f0b-44d2-afd4-a0441788b8e1
# ╠═4941b830-7327-48e5-b158-cbf0aef18474
# ╠═1ea6d8e7-ab66-410d-8cfd-c18fcfe3ce04
# ╠═b011a72b-ada0-4c40-811e-892d87a0f493
# ╠═03cd53da-88f3-4c3c-a759-d65555c4f7e9
# ╠═95730e29-8fbc-49bf-b72e-8166623473b5
# ╠═23920264-2a3c-4390-ae89-3d8a24742673
# ╠═e17beb35-f3b6-4166-b7ef-42b04fa8b7d4
# ╠═7c50f877-c53d-4cfe-b529-95c874c4a109
# ╠═933646d8-6b22-42d9-8909-2ae64c71b998
# ╠═1e3f2e6b-95b3-4c7a-bff6-d7b334f76903
# ╠═3aa84098-39c4-4e69-90ed-7311a9e623e1
# ╠═bd3458b3-7c92-4e08-aa84-d19bc26fa08b
# ╠═5693e529-6155-4631-8e93-f8c5fa87cb2f
# ╠═681a8b33-a237-4a59-be47-279e863675af
# ╠═847c2633-497a-407b-810c-9855d75b1583
# ╠═162e686a-a5a8-41f5-be21-1c8279b0ad12
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
