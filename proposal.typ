#set page(
  paper: "us-letter",
  margin: (x: 1in, y: 0.85in),
)

#set text(
  font: "New Computer Modern",
  size: 10.5pt,
)

#set par(
  justify: true,
  leading: 0.62em,
  first-line-indent: 0pt,
)

#set heading(numbering: none)
#show heading.where(level: 1): it => {
  set text(size: 11.5pt, weight: "bold")
  block(above: 1.15em, below: 0.4em)[#it.body]
}

#set list(indent: 1.1em, body-indent: 0.35em)
#set enum(indent: 1.1em, body-indent: 0.35em)

// ---------- Title Block ----------
#align(center)[
  #text(size: 13.5pt, weight: "bold")[
    Term Project Proposal: Implementation of “Improving Curl Noise”\
    (SIGGRAPH Asia 2025)
  ]
  #v(0.5em)
  #text(size: 10pt)[
    CS 450/550 · Oregon State University\
    Professor: Eugene Zhang\
    Date: November 20, 2026
  ]
]

#v(0.65em)

// ---------- Team Info ----------
#align(center)[
  #text(weight: "bold")[Team 10] \
  Logan Jordan · Haddy Alnasser · Khang Le
]

#v(0.45em)

#text(weight: "bold")[Contribution Statement] \
The proposal work, including paper selection from the SIGGRAPH and SIGGRAPH Asia lists, reading the target paper and key related work, identifying an implementable scope, and drafting this proposal, was divided evenly among all teammates. Each member contributed to the literature review, discussion of feasible subsets of the method, and writing and editing. All members intend to participate equally in the subsequent implementation, evaluation, final report, and presentation.

= Selected Paper

J. Andreas Bærentzen, Jonàs Martínez, Jeppe Revall Frisvad, and Sylvain Lefebvre. \
_Improving Curl Noise_. \
In _SIGGRAPH Asia 2025 Conference Papers_ (SA Conference Papers ’25), December 15–18, 2025, Hong Kong. ACM, New York, NY, USA, 10 pages. \
#link("https://doi.org/10.1145/3757377.3763980")[https://doi.org/10.1145/3757377.3763980]

= Problem Statement

Procedural generation of *divergence-free* vector fields is a fundamental tool in computer graphics for animating fluids, smoke, fire, particle systems, surface texturing, and point distributions. A vector field $bold(c)(bold(x))$ is divergence-free when $nabla · bold(c) = 0$. Classic curl noise produces such fields in three dimensions, but its construction is limited to the ordinary three-dimensional curl operator. In addition, numerical streamline integration accumulates error, and advected points can drift away from the intended trajectories or implicit surfaces.

The selected paper addresses these limitations with a cross product of gradients of scalar noise functions and a reprojection method that corrects integration error after each movement step. These ideas are important in computer graphics because they provide a controllable way to create fluid-like motion and procedural detail without simulating a complete fluid system. They also offer a useful connection between differential geometry, numerical integration, and practical rendering.

= Proposed Solution / Scope of Implementation

We will implement a self-contained subset of the paper suitable for a two-to-three-week, three-person term project. This is a *partial implementation*. We will build a correct three-dimensional core, the reprojection scheme, and two visual demonstrations. The paper's other applications are out of scope (see the list below).

*Core divergence-free vector field*
- Implement a twice-differentiable three-dimensional noise function in C++ and GLSL 1.20, using simplex noise or Perlin noise with the quintic fade curve. The original cubic fade is only once-differentiable.
- Compute each gradient with central differences, avoiding the need for an analytic gradient.
- Define the 3D field using two noise functions with different offsets:
  $bold(c)(bold(x)) = nabla f(bold(x)) times nabla g(bold(x))$.
- Define the 2D field from a single noise function: $bold(c)(x, y) = (f_y, -f_x)$. This is the 2D case in the paper and drives the image warp.
- Check the fields with visualizations and a numerical divergence test: the central-difference divergence of $bold(c)$ at random points should be near zero.

*Tracing and reprojection*
- Implement `dfvn_trace(x0, t, N)` with Euler integration first and fourth-order Runge–Kutta integration second.
- After each movement step, optionally apply the Newton reprojection:
  $bold(x) arrow.l bold(x) - (nabla f_i)(f_i - tau_i) / |nabla f_i|^2$.
- Keep reprojection behind a runtime toggle so that the same trace can be compared with reprojection enabled and disabled.

*Selected visual applications*
- Render a two-dimensional image warp using a full-screen quad and a sawtooth texture. The fragment shader will warp texture coordinates using the vector field and will use a constant loop bound for GLSL 1.20 compatibility.
- Render a surface warp using each mesh vertex position as the initial point and a checkerboard lookup for visualization. We will define $f_2$ as a sphere distance function so that reprojection keeps the flow on the surface. We will keep points away from the sphere center, where the distance function is not differentiable.
- If time permits, add curl noise jittering of a 3D point grid in C++. We will compare its median and minimum nearest-neighbor distance against plain random jitter, as in Table 1 of the paper.

The optional jittering experiment will not replace the required image warp and surface warp.

*Out of scope.* We will not implement dimensions above three, anisotropic curl noise through high-dimensional projection, noise bounded by a surface (Eq. 13), the Poisson disk and Sobol comparisons, or the proof of divergence-freeness. We will not claim to reproduce the whole paper.

= Implementation Plan & Tools

- *Language and rendering:* C++ will handle noise evaluation, central-difference gradients, tracing, point jittering, and metric collection. GLSL 1.20 will provide the vertex and fragment shaders for the image and surface demonstrations. An OpenGL windowing library will provide the rendering context.
- *Validation:* We will render a reference image using at least 1000 integration steps. We will then report root-mean-square error (RMSE) against it and frames per second (FPS) for Euler and fourth-order Runge–Kutta integration, with reprojection enabled and disabled, at 64 and 512 steps. These measurements correspond to Table 2 of the paper.
- *Timeline:*
  - Week 1: twice-differentiable noise, central-difference gradients, three-dimensional field, and basic divergence checks.
  - Week 2: tracing, reprojection, and the image warp.
  - Final days: surface warp, RMSE/FPS measurements, polish demonstrations, and prepare the report and presentation.
  - Optional point-jittering comparison will be attempted only after the required components are complete.

= Expected Outcomes

- Documented C++ source code and GLSL 1.20 shaders that generate the divergence-free vector field and trace points through it.
- Visual demonstrations of the three-dimensional field, Euler and Runge–Kutta traces, reprojection enabled and disabled, image warping, and surface-constrained flow.
- RMSE and FPS comparisons using the specified reference traces, together with numerical checks of the field and surface behavior.
- A short technical report documenting the mathematics, implementation choices, partial scope, validation procedure, limitations, and comparison with the selected paper.

= Risks & Mitigations

- *Noise compatibility:* GLSL 1.20 restricts shader features and loop syntax. We will use simple shader interfaces, constant loop bounds, and a noise function with a quintic fade so it stays twice differentiable.
- *Shader cost:* Each trace step needs two central-difference gradients, which is 12 noise evaluations, and RK4 needs four field evaluations per step. A long loop in one fragment shader can be slow or time out. We will compute the 1000-step reference image in C++ or in several render passes, and keep the real-time shader to 64 to 512 steps.
- *Numerical error:* Central-difference gradients and finite step sizes can introduce error. We will use fixed, documented step sizes and compare reprojection enabled and disabled under identical conditions.
- *Scope creep:* The required work is limited to the three-dimensional field, two integration methods, reprojection, and two visual applications. Point jittering and comparison with Bridson’s method are optional.