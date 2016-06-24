require_relative '../spec_helper'

describe BloomApi::Specialty do

  let (:medicare_specialty_params) {{
      "code"  => "91",
      "description" => "Physician/Surgical Oncology",
      "nucc_taxonomy_codes" => [{"code"=>"2086X0206X", "description"=>"Allopathic & Osteopathic Physicians/Surgery/Surgical Oncology"}]
  }}

  let(:medicare_specialty) { BloomApi::MedicareSpecialty.new(medicare_specialty_params) }


  describe '#code' do
    subject { medicare_specialty.code}

    it { expect(subject).to eq '91' }
  end

  describe '#description' do
    subject { medicare_specialty.description }

    it { expect(subject).to eq 'Physician/Surgical Oncology' }
  end
end
