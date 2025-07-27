# Contributing to NYC Athletic Facilities Equity Analysis

Thank you for your interest in contributing to this project! This document provides guidelines for contributing to the NYC Athletic Facilities Equity Analysis.

## 🎯 Project Overview

This project analyzes spatial distribution equity of athletic facilities in New York City, focusing on disparities in facility accessibility among different income levels and ethnic/racial groups.

## 📋 How to Contribute

### Reporting Issues

If you find a bug or have a suggestion for improvement:

1. **Check existing issues** - Search through existing issues to avoid duplicates
2. **Create a new issue** - Use the appropriate issue template
3. **Provide detailed information** - Include:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - System information (R version, OS, etc.)

### Suggesting Enhancements

For feature requests or improvements:

1. **Describe the enhancement** - What would you like to see?
2. **Explain the rationale** - Why is this enhancement useful?
3. **Provide examples** - How would this work in practice?

### Code Contributions

If you'd like to contribute code:

1. **Fork the repository** - Create your own copy
2. **Create a feature branch** - Use descriptive branch names
3. **Make your changes** - Follow the coding standards below
4. **Test your changes** - Ensure everything works correctly
5. **Submit a pull request** - Include a clear description

## 🛠️ Development Setup

### Prerequisites

- R 4.0 or higher
- Required R packages (see `scripts/00_setup.R`)
- Census API key for data access

### Local Development

```r
# Clone the repository
git clone https://github.com/yourusername/nyc-athletic-facilities-analysis.git

# Install dependencies
source("scripts/00_setup.R")

# Validate data
Rscript validate_data.R

# Run tests
source("scripts/01_data_preparation.R")
```

## 📝 Coding Standards

### R Code Style

- **Use meaningful variable names** - Descriptive and clear
- **Add comments** - Explain complex logic
- **Follow tidyverse style** - Use pipe operators and tidy functions
- **Handle errors gracefully** - Use tryCatch where appropriate
- **Document functions** - Include purpose and parameters

### File Organization

- **Scripts**: Place in `scripts/` directory
- **Documentation**: Place in `docs/` directory
- **Data**: Place in `data/` directory
- **Outputs**: Place in `output/` directory

### Naming Conventions

- **Files**: Use snake_case (e.g., `data_preparation.R`)
- **Variables**: Use snake_case (e.g., `facility_data`)
- **Functions**: Use snake_case (e.g., `calculate_density`)

## 🔍 Code Review Process

1. **Automated checks** - Code must pass validation
2. **Manual review** - At least one maintainer must approve
3. **Testing** - Ensure all scripts run without errors
4. **Documentation** - Update relevant documentation

## 📊 Data Guidelines

### Data Sources

- **Use official sources** - NYC Open Data, US Census, etc.
- **Document sources** - Include URLs and access dates
- **Respect licenses** - Follow data usage terms
- **Maintain privacy** - Don't include sensitive information

### Data Processing

- **Preserve original data** - Don't modify source files
- **Create processed versions** - Use clear naming conventions
- **Document transformations** - Explain all data modifications
- **Validate results** - Check for errors and outliers

## 🎨 Visualization Standards

### Charts and Graphs

- **Use consistent colors** - Follow project color scheme
- **Include proper labels** - Clear titles and axis labels
- **Add legends** - Explain all elements
- **Choose appropriate types** - Match visualization to data

### Maps

- **Use consistent projections** - WGS84 (EPSG:4326)
- **Include scale bars** - Show geographic scale
- **Add north arrows** - Indicate orientation
- **Use appropriate symbology** - Clear and meaningful symbols

## 📚 Documentation

### Code Documentation

- **Comment complex sections** - Explain difficult logic
- **Document functions** - Purpose, parameters, returns
- **Include examples** - Show how to use functions
- **Update README** - Keep main documentation current

### Analysis Documentation

- **Methodology** - Document analysis approach
- **Data dictionary** - Explain all variables
- **Results interpretation** - Help readers understand findings
- **Limitations** - Acknowledge study constraints

## 🚀 Release Process

### Version Control

- **Use semantic versioning** - MAJOR.MINOR.PATCH
- **Create release notes** - Document changes
- **Tag releases** - Use git tags for versions
- **Update documentation** - Keep everything current

### Quality Assurance

- **Run full analysis** - Ensure all scripts work
- **Validate outputs** - Check for errors
- **Update documentation** - Reflect all changes
- **Test reproducibility** - Verify others can reproduce results

## 🤝 Community Guidelines

### Communication

- **Be respectful** - Treat others with courtesy
- **Provide constructive feedback** - Helpful and specific
- **Ask questions** - Don't hesitate to seek clarification
- **Share knowledge** - Help others learn

### Collaboration

- **Work together** - Build on others' contributions
- **Acknowledge contributions** - Give credit where due
- **Share resources** - Help others access data and tools
- **Mentor newcomers** - Help new contributors

## 📞 Getting Help

If you need assistance:

1. **Check documentation** - Review README and docs
2. **Search issues** - Look for similar problems
3. **Ask questions** - Create an issue for help
4. **Join discussions** - Participate in community

## 🙏 Acknowledgments

We appreciate all contributions, whether they are:
- Code improvements
- Bug reports
- Documentation updates
- Feature suggestions
- Community support

Thank you for helping make this project better!

---

**Note**: This is an academic project focused on urban equity analysis. All contributions should align with the project's goal of understanding and addressing spatial inequalities in NYC. 