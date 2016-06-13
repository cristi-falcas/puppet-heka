require 'spec_helper'

describe 'heka::inputs::amqpinput', :type => 'define' do
  let(:name) { 'amqpinput' }
  let(:full_name) { "amqpinput_#{name}" }
  let(:file_name) { "/etc/heka/#{full_name}.toml" }

  # mandatory defaults
  let :params do {
      :url => 'url',
      :exchange  => 'exchange',
      :exchange_type => 'exchange_type',
    } end

  context "Remove it" do
    let :params do {
        :ensure     => 'absent',
      } end

    it do
      should contain_file($file_name).with_ensure('absent')
    end
  end

  context "Add plugin" do
    it do
      should contain_file($file_name).with({
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'root',
      })
    end

    ###########################################################################
    # defaults
    context 'with all defaults' do
      let(:params) {
        { :compress => true}
      }

      #      it do
      #        should contain_file(file_name).with(
      #        :content => '# This file is controlled via puppet.
      #        [<%= @full_name -%>]
      #        type = "AMQPInput"
      #
      #        <%= scope.function_template(['heka/plugin/_input.toml.erb']) %>
      #
      #        # specific settings
      #        url = "<%= @address -%>"
      #        exchange = "<%= @exchange -%>"
      #        exchange_type = "<%= @exchange_type -%>"
      #')
      it do
        should contain_file(file_name).
        with_content(/^\[<%= @#{full_name} -%>\]$/).
        with_content(/^type = "AMQPInput"$/)
      end
    end
  end
end
