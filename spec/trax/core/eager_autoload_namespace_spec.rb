require 'spec_helper'

describe ::Trax::Core::EagerAutoloadNamespace do
  subject { ::Ecom }

  its('autoload_class_names.length') { should eq 2 }
  its('autoload_file_paths.length') { should eq 2 }
  its(:eager_autoload_filepath) { should include('ecom') }
  its(:module_path) { should be_a(::Pathname) }
end
