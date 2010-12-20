Orchard is a Ruby library for working with Pairtrees, a filesystem hierarchy 
mapping identifiers to object directories.

More information can be found at:

  Pairtrees for Object Storage
  https://confluence.ucop.edu/display/Curation/PairTree

==== Usage Examples

  Pairtree.encode('ark:/13030/xt12t3')
  # => ark+=13030=xt12t3

  Pairtree.decode('ark+=13030=xt12t3')
  # => ark:/13030/xt12t3

  Pairtree.id_to_ppath('ark:/13030/xt12t3')
  # => ar/k+/=1/30/30/=x/t1/2t/3

  Pairtree.ppath_to_id('ar/k+/=1/30/30/=x/t1/2t/3')
  # => ark:/13030/xt12t3