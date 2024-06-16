from scipy.optimize import linprog

# Coefficients for the objective function (we minimize -40x - 30y)
c = [-40, -30]

# Coefficients for the inequality constraints
A = [[1, 1],    # x + y <= 48
     [-2, 1]]   # -2x + y >= 0

# Right-hand side of the inequality constraints
b = [48, 0]

# Bounds for x and y
x_bounds = (0, None)
y_bounds = (0, None)

# Solving the linear programming problem
result = linprog(c, A_ub=A, b_ub=b, bounds=[x_bounds, y_bounds], method='highs')

# Displaying the result
if result.success:
    print(f'Optimal number of product X: {result.x[0]:.0f}')
    print(f'Optimal number of product Y: {result.x[1]:.0f}')
    print(f'Maximized profit: ${-result.fun:.2f}')
else:
    print('No solution found')
