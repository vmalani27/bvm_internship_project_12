import dash
import dash_vtk
import pyvista as pv
from dash import html

# Load STL file with PyVista
mesh = pv.read("ROV outer frame.stl")

# Extract points and faces
points = mesh.points.tolist()
# STL faces are always triangles
cells = mesh.faces.reshape(-1, 4)[:, 1:].tolist()  # skip the first number (should be 3 for triangles)

app = dash.Dash(__name__)
app.layout = html.Div([
    dash_vtk.View([
        dash_vtk.GeometryRepresentation([
            dash_vtk.Mesh(
                points=points,
                cells=cells,
                connectivity="triangle"
            )
        ])
    ], style={"height": "600px", "width": "600px"})
])

if __name__ == "__main__":
    app.run_server(debug=True)