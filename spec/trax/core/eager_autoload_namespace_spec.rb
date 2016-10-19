require 'spec_helper'

describe ::Trax::Core::EagerAutoloadNamespace do
  subject { ::Ecom }

  its('autoload_class_names.length') { is_expected.to eq 2 }
  its('autoload_file_paths.length') { is_expected.to eq 2 }
  its(:eager_autoload_filepath) { is_expected.to include('ecom') }
  its(:module_path) { is_expected.to be_a(::Pathname) }
end
