# MASCOT: Parameter and state inference under the marginal structured coalescent approximation

Nicola F. Müller<sup>1,2</sup>, David A. Rasmussen<sup>1,2</sup>, Tanja Stadler<sup>1,2</sup>

<sup>1</sup>ETH Zurich, Department of Biosystems Science and Engineering, 4058 Basel, Switzerland

<sup>2</sup>Swiss Institute of Bioinformatics (SIB), Switzerland




## Abstract
**Motivation:** The structured coalescent is widely applied to study demography within and migration between sub-populations from genetic sequence data. Current methods are either exact but too computationally inefficient to analyse large datasets with many states, or make strong approximations leading to severe biases in inference. We recently introduced an approximation based on weaker assumptions to the structured coalescent enabling the analysis of larger datasets with many different states. We showedthat our approximation provides unbiased migration rate and population size estimates across a wideparameter range.
**Results:** We here extend this approach by providing a new algorithm to calculate the probability of the stateof internal nodes that includes the information from the full phylogenetic tree.We show that this algorithm isable to increase the probability attributed to the true node states. Furthermore we use improved integrationtechniques, such that our method is now able to analyse larger datasets, including a H3N2 dataset with433 sequences sampled from 5 different locations.
**Availability:** The here presented methods are combined into the BEAST2 package MASCOT, the MarginalApproximation of the Structured COalescenT. This package can be downloaded via the BEAUti package manager. The source code is available at [https://github.com/nicfel/Mascot.git](https://github.com/nicfel/Mascot.git).
## License

The content of this project itself is licensed under the [Creative Commons Attribution 3.0 license](http://creativecommons.org/licenses/by/3.0/us/deed.en_US), and the java source code of **esco** is licensed under the [GNU General Public License](http://www.gnu.org/licenses/).