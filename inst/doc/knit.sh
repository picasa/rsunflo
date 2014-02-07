# Model structure
dot -T pdf -o files/structure.pdf files/structure.dot
dot -T png -o files/structure.png files/structure.dot

# Documentation
pandoc -V documentclass:scrartcl documentation.md -o documentation.pdf
